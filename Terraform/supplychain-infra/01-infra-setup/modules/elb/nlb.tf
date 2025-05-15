module "nlb" {
  source = "../../../../../terraform-aws-modules-load-balancer-v2"

  name                             = var.nlb_name
  vpc_id                           = var.vpc_id
  subnets                          = var.app_subnet_ids
  load_balancer_type               = "network"
  dns_record_client_routing_policy = "availability_zone_affinity"
  enable_cross_zone_load_balancing = true
  enable_http2                     = false
  enable_deletion_protection       = true
  internal                         = true
  create_security_group            = false
  security_groups = [
    var.nlb_sg_id, var.vpc_sg_id
  ]
  preserve_host_header = true
  listeners = {
    "${var.nlb_name}-tg-listener" = {
      name     = "${var.nlb_name}-tg-listener"
      port     = 443
      protocol = "TCP"
      forward = {
        target_group_key = "${var.nlb_name}-kong-tg"
      }
      tags = merge(local.default_tags, {
        Name = "${var.nlb_name}-tg-listener",
      })
    }
  }

  target_groups = {
    "${var.nlb_name}-kong-tg" = {
      name                              = "${var.nlb_name}-kong-tg"
      protocol                          = "TCP"
      port                              = 8443
      target_type                       = "ip"
      load_balancing_cross_zone_enabled = true
      preserve_client_ip                = true
      health_check = {
        enabled           = true
        healthy_threshold = 5
        interval          = 30
        port              = 8443
        protocol          = "TCP"
      }
      create_attachment = false
      tg_tags = merge(local.default_tags, {
        Name = "${var.nlb_name}-kong-tg",
      })
    }
  }
  tags = merge(local.default_tags, {
    Name = var.nlb_name,
  })
}