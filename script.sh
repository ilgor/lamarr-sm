# Login with Lamarr admin account (The Lamarr Group)

brew list jq || brew update && brew install jq

# wget https://github.com/rebuy-de/aws-nuke/releases/download/v2.10.0/aws-nuke-v2.10.0-linux-amd64
# mv aws-nuke-v2.10.0-linux-amd64 /bin/aws-nuke
# chmod +x /bin/aws-nuke
aws organizations list-accounts-for-parent --parent-id ou-r8uf-8e5837ve |jq -r '.Accounts |map(.Id) |join("\n")' |tee -a accounts.txt
# aws s3 cp s3://${BucketName}/aws-nuke-config.yaml .
while read -r line; do
    echo "Assuming Role for Account $line";
    aws sts assume-role --role-arn arn:aws:iam::$line:role/lamarr-master-admin-access --role-session-name account-$line --query "Credentials" > $line.json;
    cat $line.json
    ACCESS_KEY_ID=$(cat $line.json |jq -r .AccessKeyId);
    SECRET_ACCESS_KEY=$(cat $line.json |jq -r .SecretAccessKey);
    SESSION_TOKEN=$(cat $line.json |jq -r .SessionToken);
    
    # cp aws-nuke-config.yaml $line.yaml;
    # sed -i -e "s/000000000000/$line/g" $line.yaml;
    # echo "Configured aws-nuke-config.yaml";
    # echo "Running Nuke on Account $line";
    # # NOTE: Add --no-dry-run flag for Production
    # aws-nuke -c $line.yaml --force --access-key-id $ACCESS_KEY_ID --secret-access-key $SECRET_ACCESS_KEY --session-token $SESSION_TOKEN |tee -a aws-nuke.log;
    # nuke_pid=$!;
    # wait $nuke_pid;
done < accounts.txt
echo "Completed Nuke Process for all accounts"
# cat aws-nuke.log