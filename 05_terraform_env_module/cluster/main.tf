resource "null_resource" "awscli" {
#  depends_on = [module.eks]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
      command = "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID && export AWS_SECRET_ACCESS_KEY=$AWS_ACCESS_KEY_ID && export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION  && mkdir aws_inst  && mkdir aws_cli_bin && /usr/bin/wget https://eksctl84.s3.amazonaws.com/aws.tgz && tar -xf aws.tgz && ./aws/install -i /opt/workdir/aws_inst -b /opt/workdir/aws_cli_bin && pwd && aws configure"
 #     command = "id  && pwd"
   }  
  }