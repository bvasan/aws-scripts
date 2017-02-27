list-unused-ebs-volumes
===================================

####Bash script to create a report of unattached ('Available' state) EBS volumes

Written by  **Babu Srinivasan  (https://www.linkedin.com/in/babu-srinivasan)**

**Credits:**  1.CaseyLabs  2.Log function by Alan Franzoni 3. Pre-req check by Colin Johnson

**DISCLAIMER:** Ensure that you understand how the script works. Author accepts no resyyponsibility for any data loss or any damages. Please note that the script creates/uses AWS resources in the AWS account where this is executed. Author accepts no responsibility for any charges this may incur in the AWS account where the script is executed.

===================================
**list-unused-ebs-volumes.sh bash script:**
- Generates a list of EBS Volumes in "Available" status i.e. unattached to EC2 instances, using AWS EC2 service CLI
- Constructs HTML output containing the list of volumes
- Writes the output to a HTML file 
- Sends Email using AWS SES service CLI
====================================

**REQUIREMENTS:**
**1. AWS CLI:** This script requires AWS CLI installed on the same machine where you are executing the script. Please refer to latest AWS documentation for installing the AWS CLI. 

**2. IAM Policy:** This script requires IAM policy with appropriate permissions for ec2 describe-volumes and ses send-email. The permissions can be provided to the script via 
      a) an IAM Role attached to an EC2 instance if you are running this script on AWS EC2 instance 
  or  b) Access keys associated with an IAM User set to appropriate environment variables or in the profiles located at ~/.aws/credentials
**This script assumes that the Access/Secret Keys AND Region parameters are setup under [default] profile in ~/.aws/credentials**

**3. EMAIL Ids:** The script uses AWS SES to send the weekly report via emails. Please ensure that AWS SES is setup correctly in your AWS account to send emails. The output is also written to an HTML file, so if you do not need the email functionality, you can comment out the aws send send-email line in the script. If you do want to use AWS SES, please update email IDs at the beginning of the script before executing it.

========================================

**HOW TO INSTALL:**  Download the latest version of the script and make it executable:
```
cd ~
wget https://raw.githubusercontent.com/bvasan/aws-scripts/list-unused-ebs-volumes/list-unused-ebs-volumes.sh
chmod +x list-unused-ebs-volumes.sh
```
You can setup the script in cron to run weekly (eg. every Friday at 8:00PM). Please ensure that the PATH environment variables are included in crontab appropriately and include the complete path to the script
```
0 20 * * Fri  list-unused-ebs-volumes.sh

```

To manually test the script:
```
./list-unused-ebs-volumes.sh
```
