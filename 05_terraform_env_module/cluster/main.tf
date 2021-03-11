resource "null_resource" "awscli" {
#  depends_on = [module.eks]    
  triggers = {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
  #     command = "/usr/bin/wget https://eksctl84.s3.amazonaws.com/aws && chmod +x aws && cp aws /usr/local/bin"
     
   }  
  }