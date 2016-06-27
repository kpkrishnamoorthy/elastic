# See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "krishnamoorthy"
client_key               "#{current_dir}/krishnamoorthy.pem"
chef_server_url          "https://api.chef.io/organizations/kpkrishnamoorthy"
cookbook_path            ["#{current_dir}/../cookbooks"]

# knife[:aws_credential_file] = File.expand_path("~/.aws/credentials")
knife[:aws_access_key_id]         = ENV['AWS_ACCESS_KEY_ID']
knife[:aws_secret_access_key]     = ENV['AWS_SECRET_ACCESS_KEY']
knife[:region]                    = "us-west-2"
knife[:identity_file]             = "./kpkrishnamoorthy.pem"
knife[:ssh_key_name]              = "kpkrishnamoorthy"
knife[:image]                     = "ami-d06a90b0" # Ubuntu Xenial base image
knife[:flavor]                    = "t2.micro"
knife[:ssh_user]                  = "ubuntu"
knife[:run_list]                  = [
                                      "role[elasticsearch]",
                                    ]
knife[:server_connect_attribute]  = "public_ip_address"
