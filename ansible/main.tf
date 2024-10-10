resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      site_a_public_ip = var.site_a_public_ip
      site_b_public_ip = var.site_b_public_ip
    }
  )
  filename = "${path.module}/inventory.ini"
}

resource "local_file" "playbook_vars" {
  content = templatefile("${path.module}/templates/playbook_vars.tmpl",
    {
      site_a_public_ip  = var.site_a_public_ip
      site_a_private_ip = var.site_a_private_ip
      site_b_public_ip  = var.site_b_public_ip
      site_b_private_ip = var.site_b_private_ip

    }
  )
  filename = "${path.module}/playbook_vars.yaml"
}