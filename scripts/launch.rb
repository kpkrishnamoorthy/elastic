require 'json'
require 'net/http'
print "Please enter your AWS Access Key: "
ENV['AWS_ACCESS_KEY_ID']      = gets()
print "Please enter your AWS Secret: "
ENV['AWS_SECRET_ACCESS_KEY']  = gets()

# Create and configure VPC and networking
vpc = JSON.parse(`aws ec2 create-vpc --cidr-block 10.0.0.0/16`)["Vpc"]["VpcId"]
internet_gateway = JSON.parse(`aws ec2 create-internet-gateway`)["InternetGateway"]["InternetGatewayId"]
`aws ec2 attach-internet-gateway --internet-gateway-id '#{internet_gateway}' --vpc-id '#{vpc}'`
route_tables = JSON.parse(`aws ec2 describe-route-tables`)
route_table_id = ""
route_tables["RouteTables"].each {|r| route_table_id = r["RouteTableId"] if r["VpcId"] == vpc }
`aws ec2 create-route --route-table-id #{route_table_id} --destination-cidr-block 0.0.0.0/0 --gateway-id #{internet_gateway}`

security_group = JSON.parse(`aws ec2 create-security-group --group-name elasticsearch --description elasticsearch --vpc-id '#{vpc}'`)["GroupId"]
subnet = JSON.parse(`aws ec2 create-subnet --vpc-id '#{vpc}' --cidr-block '10.0.1.0/24'`)["Subnet"]["SubnetId"]
`aws ec2 modify-subnet-attribute --subnet-id '#{subnet}' --map-public-ip-on-launch`
my_public_ip = Net::HTTP.get URI "https://api.ipify.org"

`aws ec2 authorize-security-group-ingress --group-id #{security_group} --protocol tcp --port 22 --cidr #{my_public_ip}/32`
`aws ec2 authorize-security-group-ingress --group-id #{security_group} --protocol tcp --port 9200 --cidr #{my_public_ip}/32`
`aws ec2 authorize-security-group-ingress --group-id #{security_group} --protocol all --port all --source-group #{security_group}`
`aws ec2 delete-key-pair --key-name 'kpkrishnamoorthy'`
aws_private_key = JSON.parse(`aws ec2 create-key-pair --key-name 'kpkrishnamoorthy'`)
File.open("kpkrishnamoorthy.pem", "w+") { |f| f.write(aws_private_key["KeyMaterial"]) }
`chmod 600 kpkrishnamoorthy.pem`

# Launch instances
3.times { system("bundle exec knife ec2 server create -g '#{security_group}' --subnet #{subnet}") }

# Re-run Chef on instances so they find each other and form a cluster
instances = Array.new
JSON.parse(`bundle exec knife search node 'role:elasticsearch' -F json -a ec2.public_ipv4`)["rows"].each {|i| instances << i.values.first["ec2.public_ipv4"] }
instances.each do |ip|
  system("ssh ubuntu@#{ip} -i kpkrishnamoorthy.pem 'sudo chef-client'")
end
