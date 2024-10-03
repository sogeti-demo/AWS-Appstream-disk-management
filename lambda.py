import boto3
import os
from datetime import datetime

PREFIX = os.environ.get('PREFIX')
BUCKET = os.environ.get('BUCKET')
TABLE = os.environ.get('TABLE')
BATCH_SIZE = int(os.environ.get('BATCH_SIZE'))
SSM_DOCUMENT = os.environ.get('SSM_DOCUMENT')
SSM_DOCUMENT_VERSION = os.environ.get('SSM_DOCUMENT_VERSION')
EC2_INSTANCE = os.environ.get('EC2_INSTANCE')
LOGGROUPNAME = os.environ.get('LOGGROUPNAME')

s3 = boto3.client('s3')
ddb = boto3.client('dynamodb', region_name='eu-west-1')
ssm = boto3.client('ssm', region_name='eu-west-1')
ec2 = boto3.resource('ec2')
ec2_instance = ec2.Instance(EC2_INSTANCE)
ec2 = boto3.client('ec2', region_name='eu-west-1')
logs = boto3.client('logs', region_name='eu-west-1')
valid_users = []


current_datetime = datetime.now()
datestamp = current_datetime.strftime("%Y/%m/%d/%H.%M.%S")

logs.create_log_stream(
    logGroupName=LOGGROUPNAME,
    logStreamName=datestamp
)

def log(message):
    logs.put_log_events(
        logGroupName=LOGGROUPNAME,
        logStreamName=datestamp,
        logEvents=[
            {
                'timestamp': int(datetime.utcnow().timestamp()*1000),
                'message': message
            },
        ]
    )
    if 'prefix' not in os.environ:
        print(message)


log('starting processing at lambda-level')

def lambda_handler(event, context): 
    test = False
    result = s3.list_objects(Bucket=BUCKET, Prefix=PREFIX, Delimiter='/', MaxKeys=2)
    while True:
        for cp in result['CommonPrefixes']:
            uhash = cp['Prefix'].split('/')[-2]
            response = ddb.get_item(
                TableName=TABLE,
                Key={
                    'UserHash': {'S': uhash},
                }
            )
            if 'Item' not in response:
                valid_users.append(uhash)
                if len(valid_users) >= BATCH_SIZE: break
        
    
        if len(valid_users) >= BATCH_SIZE: break
        elif result['IsTruncated']: 
            nextmarker = result['NextMarker']
            result = s3.list_objects(Bucket=BUCKET, Prefix=PREFIX, Delimiter='/', Marker=nextmarker)
        else:
            break
    
    print(valid_users)
    
    if len(valid_users) >= 1 and test == False:

        ec2.start_instances(
            InstanceIds=[EC2_INSTANCE]
        )

        log('Found valid users: ' + str(valid_users))
        log('Starting windows...')

        ec2_instance.wait_until_running()
    
        result = ssm.send_command(
            InstanceIds=[EC2_INSTANCE],
            DocumentName=SSM_DOCUMENT,
            Parameters={
                'HashList': [
                    ','.join(valid_users),
                ],
                'DynamoTable': [
                    TABLE
                ],
                'S3AppsettingsBuckets': [
                    BUCKET
                ],
                'logGroupName': [
                    LOGGROUPNAME
                ],
                'logstreamname': [
                    datestamp
                ]
            }
        )
        log(f"SSM Command send succesfully. Find further logs at https://eu-west-1.console.aws.amazon.com/systems-manager/run-command/{ result['Command']['CommandId'] }?region=eu-west-1")
    else:
        log(f"No users require updating.")
    
    log("Exiting Lambda...")
    return {
        'statusCode': 200,
         "headers": {
            "Content-Type": "application/json"
        },
        "body": "success"
    }


if 'prefix' not in os.environ:
    lambda_handler(1,1)