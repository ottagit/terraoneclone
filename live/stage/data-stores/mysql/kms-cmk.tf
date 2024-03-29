# Fetch the current user's info - username, ARN, etc
data "aws_caller_identity" "self" {}

# Create a key policy that gives the current user admin
# admin permissions over AWS KMS Customer Managed Key
data "aws_iam_policy_document" "cmk_admin_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.self.arn]
    }
  }
}

# Create the CMK
resource "aws_kms_key" "cmk" {
  policy = data.aws_iam_policy_document.cmk_admin_policy.json
}

# Create a human-friendly alias for the CMK
resource "aws_kms_alias" "cmk" {
  name          = "alias/db-kms-cmk"
  target_key_id = aws_kms_key.cmk.id
}