output "jenkins_public_ip" {
  description = "Public IP of the Jenkins server"
  value       = aws_instance.jenkins.public_ip
}
