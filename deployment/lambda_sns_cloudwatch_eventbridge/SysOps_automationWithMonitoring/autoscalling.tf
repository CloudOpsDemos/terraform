resource "aws_launch_template" "autoscalling" {
    name_prefix   = "${local.prefix_env}-autoscalling-"
    image_id      = "ami-00c257e12d6828491"
    instance_type = "t2.nano"
    
    lifecycle {
        create_before_destroy = true
    }
    
    tag_specifications {
        resource_type = "instance"
    
        tags = {
        Name = "${local.prefix_env}-autoscalling-instance"
        }
    }
    
    monitoring {
        enabled = true
    }

    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            volume_size           = 8
            volume_type           = "gp2"
            delete_on_termination = true
        }
    }

    user_data = filebase64("user_data/autoscalling.sh")
}

resource "aws_autoscaling_group" "autoscalling" {
    desired_capacity     = 2
    max_size             = 3
    min_size             = 1
    vpc_zone_identifier = module.vpc.public_subnets
    launch_template {
        id      = aws_launch_template.autoscalling.id
        version = aws_launch_template.autoscalling.latest_version
    }
    health_check_grace_period = 150
    health_check_type = "EC2"
    force_delete = true
    enabled_metrics = ["GroupTotalInstances"]
    protect_from_scale_in = true
    tag {
        key                 = "Name"
        value               = "${local.prefix_env}-autoscalling-instance"
        propagate_at_launch = true
    }
}