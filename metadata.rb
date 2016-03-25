name             "kafka"
description      "Install and configure kafka"
maintainer       "Heavy Water Operations, LLC"
maintainer_email "helpdesk@heavywater.io"
license          "Apache 2.0"
version          "0.2.7"
source_url        "https://github.com/hw-cookbooks/kafka" if respond_to?(:source_url)
issues_url        "https://github.com/hw-cookbooks/kafka/issues" if respond_to?(:issues_url)

supports "debian"
supports "rhel"

depends "java",  ">= 1.11.4"
depends "runit", ">= 1.1.4"
depends "builder", ">= 0.1.1"
depends "zookeeperd", ">= 0.1.0"
depends "ark"
