data "template_file" "demo-web-service" {
  count    = "${var.run}"
  template = "${file("./templates/demo-web-service.nomad")}"

  vars {
    job_name    = "${var.job_name}"
    region      = "${var.regions}"
    datacenters = "${var.datacenters}"
    cpu_limit   = "${var.cpu_limit}"
    mem_limit   = "${var.mem_limit}"
    net_limit   = "${var.net_limit}"
  }
}

resource "nomad_job" "demo-web-service" {
  jobspec = "${data.template_file.demo-web-service.rendered}"
}
