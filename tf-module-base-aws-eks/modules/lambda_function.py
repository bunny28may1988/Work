import json
import boto3
import time

def lambda_handler(event, context):
    # TODO implement
    print(event)
    # eks_client = boto3.client('eks')
    # eks_response = eks_client.describe_cluster(name=event['key1'])
    # print(eks_response['cluster']['version'])
    # print(event['key2'])
    # if(eks_response['cluster']['version'] != event['key2']):


    # # if()
    
    try:
        eks_client = boto3.client('eks')
        ssm_client = boto3.client('ssm')
        ec2_client = boto3.client('ec2')
        eks_version = eks_client.describe_cluster(name=event["key1"])
        eks_version=eks_version['cluster']['version']
        nodegroups_response = eks_client.list_nodegroups(clusterName=event["key1"])
        for nodegroup_name in nodegroups_response['nodegroups']:
                # Describe the specific nodegroup to get details
                nodegroup_details = eks_client.describe_nodegroup(
                    clusterName=event["key1"],
                    nodegroupName=nodegroup_name
                )

                launch_template = nodegroup_details['nodegroup']['launchTemplate']
                launch_template_version = launch_template.get('version', '$Latest')
                
                # Get launch template details
                lt_response = ec2_client.describe_launch_template_versions(
                    LaunchTemplateId=launch_template['id'],
                    Versions=[str(launch_template_version)]
                )

                ami_id = lt_response['LaunchTemplateVersions'][0]['LaunchTemplateData'].get('ImageId')
                
                print(ami_id)
                print(nodegroup_name)

                #update ssm params

                ssm_client.put_parameter(
                    Name = event["key1"]+"-version",
                    Value = eks_version,
                    Overwrite = True,
                    Type = 'String'

                )

                ssm_client.put_parameter(
                    Name = nodegroup_name,
                    Value = ami_id,
                    Overwrite = True,
                    Type = 'String'

                )

                print("ssm params updated successfully")
    except Exception as e:
        print(e)

    # time.sleep()   
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
