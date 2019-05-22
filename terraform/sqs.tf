resource "aws_sqs_queue" "slash_commands" {
  name = "${title(var.namespace)}SlashCommands"
}
