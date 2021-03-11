resource "null_resource" "awscli" {
#  depends_on = [module.eks]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
 #     command = "/usr/bin/wget https://eksctl84.s3.amazonaws.com/aws.tgz && tar -xf aws.tgz && ./aws/install -i /usr/local/aws-cli -b /usr/local/bin"
      command = "id  && pwd"
   }  
  }