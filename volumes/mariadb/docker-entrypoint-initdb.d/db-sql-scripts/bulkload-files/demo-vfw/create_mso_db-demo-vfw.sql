SOURCE ../default/create_mso_db-default.sql

USE `mso_requests`;
DROP USER 'mso';
CREATE USER 'mso';
GRANT ALL on mso_requests.* to 'mso' identified by 'mso123' with GRANT OPTION;
FLUSH PRIVILEGES;

USE `mso_catalog`;
DROP USER 'catalog';
CREATE USER 'catalog';
GRANT ALL on mso_catalog.* to 'catalog' identified by 'catalog123' with GRANT OPTION;
FLUSH PRIVILEGES;

LOCK TABLES `heat_environment` WRITE;
/*!40000 ALTER TABLE `heat_environment` DISABLE KEYS */;
INSERT INTO `heat_environment` VALUES (5,'base_vfw.env','1.0','vfw-service/VFWResource-1','base_vfw ENV file','parameters:\n  vfw_image_name: Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)\n  vfw_flavor_name: 4 GB General Purpose v1\n  public_net_id: 00000000-0000-0000-0000-000000000000\n  unprotected_private_net_id: zdfw1fwl01_unprotected\n  protected_private_net_id: zdfw1fwl01_protected\n  ecomp_private_net_id: oam_ecomp\n  unprotected_private_net_cidr: 192.168.10.0/24\n  protected_private_net_cidr: 192.168.20.0/24\n  ecomp_private_net_cidr: 192.168.9.0/24\n  vfw_private_ip_0: 192.168.10.100\n  vfw_private_ip_1: 192.168.20.100\n  vfw_private_ip_2: 192.168.9.100\n  vpg_private_ip_0: 192.168.10.200\n  vpg_private_ip_1: 192.168.9.200\n  vsn_private_ip_0: 192.168.20.250\n  vsn_private_ip_1: 192.168.9.250\n  vfw_name_0: zdfw1fwl01fwl01\n  vpg_name_0: zdfw1fwl01pgn01\n  vsn_name_0: zdfw1fwl01snk01\n  vnf_id: vFirewall_demo_app\n  vf_module_id: vFirewall\n  webserver_ip: 162.242.237.182\n  dcae_collector_ip: 192.168.9.1\n  key_name: vfw_key\n  pub_key: INSERT YOUR PUBLIC KEY HERE','2016-11-14 13:04:07','EnvArtifact-UUID3','Label');
/*!40000 ALTER TABLE `heat_environment` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `heat_template` WRITE;
/*!40000 ALTER TABLE `heat_template` DISABLE KEYS */;
INSERT INTO `heat_template` VALUES (8,'base_vfw.yaml','1.0','VFWResource','base_vfw.yaml','heat_template_version: 2013-05-23\n\ndescription: Heat template to deploy vFirewall demo app for OpenECOMP\n\nparameters:\n  vfw_image_name:\n    type: string\n    label: Image name or ID\n    description: Image to be used for compute instance\n  vfw_flavor_name:\n    type: string\n    label: Flavor\n    description: Type of instance (flavor) to be used\n  public_net_id:\n    type: string\n    label: Public network name or ID\n    description: Public network that enables remote connection to VNF\n  unprotected_private_net_id:\n    type: string\n    label: Unprotected private network name or ID\n    description: Private network that connects vPacketGenerator with vFirewall\n  protected_private_net_id:\n    type: string\n    label: Protected private network name or ID\n    description: Private network that connects vFirewall with vSink\n  ecomp_private_net_id:\n    type: string\n    label: ECOMP management network name or ID\n    description: Private network that connects ECOMP component and the VNF\n  unprotected_private_net_cidr:\n    type: string\n    label: Unprotected private network CIDR\n    description: The CIDR of the unprotected private network\n  protected_private_net_cidr:\n    type: string\n    label: Protected private network CIDR\n    description: The CIDR of the protected private network\n  ecomp_private_net_cidr:\n    type: string\n    label: ECOMP private network CIDR\n    description: The CIDR of the protected private network\n  vfw_private_ip_0:\n    type: string\n    label: vFirewall private IP address towards the unprotected network\n    description: Private IP address that is assigned to the vFirewall to communicate with the vPacketGenerator\n  vfw_private_ip_1:\n    type: string\n    label: vFirewall private IP address towards the protected network\n    description: Private IP address that is assigned to the vFirewall to communicate with the vSink\n  vfw_private_ip_2:\n    type: string\n    label: vFirewall private IP address towards the ECOMP management network\n    description: Private IP address that is assigned to the vFirewall to communicate with ECOMP components\n  vpg_private_ip_0:\n    type: string\n    label: vPacketGenerator private IP address towards the unprotected network\n    description: Private IP address that is assigned to the vPacketGenerator to communicate with the vFirewall\n  vpg_private_ip_1:\n    type: string\n    label: vPacketGenerator private IP address towards the ECOMP management network\n    description: Private IP address that is assigned to the vPacketGenerator to communicate with ECOMP components\n  vsn_private_ip_0:\n    type: string\n    label: vSink private IP address towards the protected network\n    description: Private IP address that is assigned to the vSink to communicate with the vFirewall\n  vsn_private_ip_1:\n    type: string\n    label: vSink private IP address towards the ECOMP management network\n    description: Private IP address that is assigned to the vSink to communicate with ECOMP components\n  vfw_name_0:\n    type: string\n    label: vFirewall name\n    description: Name of the vFirewall\n  vpg_name_0:\n    type: string\n    label: vPacketGenerator name\n    description: Name of the vPacketGenerator\n  vsn_name_0:\n    type: string\n    label: vSink name\n    description: Name of the vSink\n  vnf_id:\n    type: string\n    label: VNF ID\n    description: The VNF ID is provided by ECOMP\n  vf_module_id:\n    type: string\n    label: vFirewall module ID\n    description: The vFirewall Module ID is provided by ECOMP\n  webserver_ip:\n    type: string\n    label: Webserver IP address\n    description: IP address of the webserver that hosts the source code and binaries\n  dcae_collector_ip:\n    type: string\n    label: DCAE collector IP address\n    description: IP address of the DCAE collector\n  key_name:\n    type: string\n    label: Key pair name\n    description: Public/Private key pair name\n  pub_key:\n    type: string\n    label: Public key\n    description: Public key to be installed on the compute instance\n\nresources:\n  my_keypair:\n    type: OS::Nova::KeyPair\n    properties:\n      name: { get_param: key_name }\n      public_key: { get_param: pub_key }\n      save_private_key: false\n\n  unprotected_private_network:\n    type: OS::Neutron::Net\n    properties:\n      name: { get_param: unprotected_private_net_id }\n\n  protected_private_network:\n    type: OS::Neutron::Net\n    properties:\n      name: { get_param: protected_private_net_id }\n\n  unprotected_private_subnet:\n    type: OS::Neutron::Subnet\n    properties:\n      network_id: { get_resource: unprotected_private_network }\n      cidr: { get_param: unprotected_private_net_cidr }\n\n  protected_private_subnet:\n    type: OS::Neutron::Subnet\n    properties:\n      network_id: { get_resource: protected_private_network }\n      cidr: { get_param: protected_private_net_cidr }\n\n  vfw_0:\n    type: OS::Nova::Server\n    properties:\n      image: { get_param: vfw_image_name }\n      flavor: { get_param: vfw_flavor_name }\n      name: { get_param: vfw_name_0 }\n      key_name: { get_resource: my_keypair }\n      networks:\n        - network: { get_param: public_net_id }\n        - port: { get_resource: vfw_private_0_port }\n        - port: { get_resource: vfw_private_1_port }\n        - port: { get_resource: vfw_private_2_port }\n      metadata: {vnf_id: { get_param: vnf_id }, vf_module_id: { get_param: vf_module_id }}\n      user_data_format: RAW\n      user_data:\n        str_replace:\n          params:\n            __webserver__: { get_param: webserver_ip }\n            __dcae_collector_ip__ : { get_param: dcae_collector_ip }\n          template: |\n            #!/bin/bash\n\n            WEBSERVER_IP=__webserver__\n            DCAE_COLLECTOR_IP=__dcae_collector_ip__\n\n            mkdir /opt/config\n            cd /opt\n            wget http://$WEBSERVER_IP/demo_repo/v_firewall_init.sh\n            wget http://$WEBSERVER_IP/demo_repo/vfirewall.sh\n            chmod +x v_firewall_init.sh\n            chmod +x vfirewall.sh\n            echo $WEBSERVER_IP > config/webserver_ip.txt\n            echo $DCAE_COLLECTOR_IP > config/dcae_collector_ip.txt\n            echo "no" > config/install.txt\n            mv vfirewall.sh /etc/init.d\n            sudo update-rc.d vfirewall.sh defaults\n            ./v_firewall_init.sh\n\n  vfw_private_0_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_resource: unprotected_private_network }\n      fixed_ips: [{"subnet": { get_resource: unprotected_private_subnet }, "ip_address": { get_param: vfw_private_ip_0 }}]\n\n  vfw_private_1_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_resource: protected_private_network }\n      fixed_ips: [{"subnet": { get_resource: protected_private_subnet }, "ip_address": { get_param: vfw_private_ip_1 }}]\n\n  vfw_private_2_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: ecomp_private_net_id }\n      fixed_ips: [{"subnet": { get_param: ecomp_private_net_id }, "ip_address": { get_param: vfw_private_ip_2 }}]\n\n  vpg_0:\n    type: OS::Nova::Server\n    properties:\n      image: { get_param: vfw_image_name }\n      flavor: { get_param: vfw_flavor_name }\n      name: { get_param: vpg_name_0 }\n      key_name: { get_resource: my_keypair }\n      networks:\n        - network: { get_param: public_net_id }\n        - port: { get_resource: vpg_private_0_port }\n        - port: { get_resource: vpg_private_1_port }\n      metadata: {vnf_id: { get_param: vnf_id }, vf_module_id: { get_param: vf_module_id }}\n      user_data_format: RAW\n      user_data:\n        str_replace:\n          params:\n            __webserver__: { get_param: webserver_ip }\n            __fw_ipaddr__: { get_param: vfw_private_ip_0 }\n            __protected_net_cidr__: { get_param: protected_private_net_cidr }\n            __sink_ipaddr__: { get_param: vsn_private_ip_0 }\n          template: |\n            #!/bin/bash\n\n            WEBSERVER_IP=__webserver__\n            FW_IPADDR=__fw_ipaddr__\n            PROTECTED_NET_CIDR=__protected_net_cidr__\n            SINK_IPADDR=__sink_ipaddr__\n\n            mkdir /opt/config\n            cd /opt\n            wget http://$WEBSERVER_IP/demo_repo/v_packetgen_init.sh\n            wget http://$WEBSERVER_IP/demo_repo/vpacketgen.sh\n            chmod +x v_packetgen_init.sh\n            chmod +x vpacketgen.sh\n            echo $WEBSERVER_IP > config/webserver_ip.txt\n            echo $FW_IPADDR > config/fw_ipaddr.txt\n            echo $PROTECTED_NET_CIDR > config/protected_net_cidr.txt\n            echo $SINK_IPADDR > config/sink_ipaddr.txt\n            echo "no" > config/install.txt\n            mv vpacketgen.sh /etc/init.d\n            sudo update-rc.d vpacketgen.sh defaults\n            ./v_packetgen_init.sh\n\n  vpg_private_0_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_resource: unprotected_private_network }\n      fixed_ips: [{"subnet": { get_resource: unprotected_private_subnet }, "ip_address": { get_param: vpg_private_ip_0 }}]\n\n  vpg_private_1_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: ecomp_private_net_id }\n      fixed_ips: [{"subnet": { get_param: ecomp_private_net_id }, "ip_address": { get_param: vpg_private_ip_1 }}]\n\n  vsn_0:\n    type: OS::Nova::Server\n    properties:\n      image: { get_param: vfw_image_name }\n      flavor: { get_param: vfw_flavor_name }\n      name: { get_param: vsn_name_0 }\n      key_name: { get_resource: my_keypair }\n      networks:\n        - network: { get_param: public_net_id }\n        - port: { get_resource: vsn_private_0_port }\n        - port: { get_resource: vsn_private_1_port }\n      metadata: {vnf_id: { get_param: vnf_id }, vf_module_id: { get_param: vf_module_id }}\n      user_data_format: RAW\n      user_data:\n        str_replace:\n          params:\n            __webserver__: { get_param: webserver_ip }\n            __protected_net_gw__: { get_param: vfw_private_ip_1 }\n            __unprotected_net__: { get_param: unprotected_private_net_cidr }\n          template: |\n            #!/bin/bash\n\n            WEBSERVER_IP=__webserver__\n            PROTECTED_NET_GW=__protected_net_gw__\n            UNPROTECTED_NET=__unprotected_net__\n            UNPROTECTED_NET=$(echo $UNPROTECTED_NET | cut -d\'/\' -f1)\n\n            mkdir /opt/config\n            cd /opt\n            wget http://$WEBSERVER_IP/demo_repo/v_sink_init.sh\n            wget http://$WEBSERVER_IP/demo_repo/vsink.sh\n            chmod +x v_sink_init.sh\n            chmod +x vsink.sh\n            echo $PROTECTED_NET_GW > config/protected_net_gw.txt\n            echo $UNPROTECTED_NET > config/unprotected_net.txt\n            echo "no" > config/install.txt\n            mv vsink.sh /etc/init.d\n            sudo update-rc.d vsink.sh defaults\n            ./v_sink_init.sh\n\n  vsn_private_0_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_resource: protected_private_network }\n      fixed_ips: [{"subnet": { get_resource: protected_private_subnet }, "ip_address": { get_param: vsn_private_ip_0 }}]\n\n  vsn_private_1_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: ecomp_private_net_id }\n      fixed_ips: [{"subnet": { get_param: ecomp_private_net_id }, "ip_address": { get_param: vsn_private_ip_1 }}]\n \n',300,'Artifact-UUID3','Base VFW Heat','label','2016-11-14 13:04:07',NULL);
/*!40000 ALTER TABLE `heat_template` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `heat_template_params` WRITE;
/*!40000 ALTER TABLE `heat_template_params` DISABLE KEYS */;
INSERT INTO `heat_template_params` VALUES (144,8,'vsn_private_ip_1','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (145,8,'ecomp_private_net_cidr','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (146,8,'public_net_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (147,8,'unprotected_private_net_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (148,8,'webserver_ip','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (149,8,'vfw_image_name','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (150,8,'vnf_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (151,8,'dcae_collector_ip','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (152,8,'protected_private_net_cidr','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (153,8,'vsn_private_ip_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (154,8,'vfw_private_ip_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (155,8,'vfw_private_ip_1','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (156,8,'vfw_private_ip_2','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (157,8,'unprotected_private_net_cidr','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (158,8,'vsn_name_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (159,8,'ecomp_private_net_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (160,8,'vpg_private_ip_1','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (161,8,'vpg_name_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (162,8,'vf_module_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (163,8,'pub_key','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (164,8,'protected_private_net_id','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (165,8,'key_name','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (166,8,'vfw_flavor_name','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (167,8,'vpg_private_ip_0','\1','string',NULL);
INSERT INTO `heat_template_params` VALUES (168,8,'vfw_name_0','\1','string',NULL);
/*!40000 ALTER TABLE `heat_template_params` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `service` WRITE;
/*!40000 ALTER TABLE `service` DISABLE KEYS */;
INSERT INTO `service` VALUES (11,'vfw-service','1.0','VFW service','2e34774e-715e-4fd5-bd09-7b654622f35i',NULL,NULL,'2016-11-14 13:04:07','585822c7-4027-4f84-ba50-e9248606f112');
/*!40000 ALTER TABLE `service` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `vf_module` WRITE;
/*!40000 ALTER TABLE `vf_module` DISABLE KEYS */;
INSERT INTO `vf_module` VALUES (9,'vfw-service/VFWResource-1::VF_RI1_VFW::module-1','1.0','VF_RI1_VFW::module-1','1.0','1e34774e-715e-4fd5-bd08-7b654622f33f.VF_RI1_VFW::module-1::module-1.group',NULL,8,1,'2016-11-14 13:04:07',NULL,NULL,7,5,'585822c7-4027-4f84-ba50-e9248606f134');
/*!40000 ALTER TABLE `vf_module` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `vnf_resource` WRITE;
/*!40000 ALTER TABLE `vnf_resource` DISABLE KEYS */;
INSERT INTO `vnf_resource` VALUES (7,'vfw-service/VFWResource-1','1.0','HEAT','VFW service',NULL,NULL,'2016-11-14 13:04:07','685822c7-4027-4f84-ba50-e9248606f132',NULL,NULL,'585822c7-4027-4f84-ba50-e9248606f113','1.0','VFWResource-1','VFWResource','585822c7-4027-4f84-ba50-e9248606f112');
/*!40000 ALTER TABLE `vnf_resource` ENABLE KEYS */;
UNLOCK TABLES;