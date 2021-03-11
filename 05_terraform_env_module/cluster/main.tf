resource "null_resource" "awscli" {
#  depends_on = [module.eks]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
      command = "mkdir aws_inst  && mkdir aws_cli_bin && /usr/bin/wget https://eksctl84.s3.amazonaws.com/aws.tgz && tar -xf aws.tgz && ./aws/install -i /opt/workdir/aws_inst -b /opt/workdir/aws_cli_bin && pwd && /opt/workdir/aws_cli_bin/aws --version  && which aws && echo $PATH"
 #     command = "id  && pwd"
   }  
  }