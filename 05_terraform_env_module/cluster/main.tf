resource "null_resource" "awscli" {
#  depends_on = [module.eks]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
      command = "mkdir aws_inst  && mkdir aws_cli_bin && /usr/bin/wget https://eksctl84.s3.amazonaws.com/aws.tgz && tar -xf aws.tgz && ./aws/install -i aws_inst -b aws_cli_bin && aws_cli_bin/aws --version"
 #     command = "id  && pwd"
   }  
  }