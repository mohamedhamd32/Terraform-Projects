variable "name" {
  description = "Name of the ECR repository."
  type        = string
}

variable "force_delete" {
  description = "Delete the repository even if it still contains images. Convenient for practice environments."
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Number of images to retain. Older images are expired automatically."
  type        = number
  default     = 10
}
