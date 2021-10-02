# Changelog

# [2.2.0](https://github.com/saltstack-formulas/airflow-formula/compare/v2.1.2...v2.2.0) (2021-10-02)


### Bug Fixes

* **cent7:** ensure pyopenssl is installed explicitly ([95b14d9](https://github.com/saltstack-formulas/airflow-formula/commit/95b14d90d9ac78d0257e73993bdd18c8fb724ab9))
* **database:** avoid fe_sendauth no password supplied ([834fd99](https://github.com/saltstack-formulas/airflow-formula/commit/834fd99432b73f237eef5bb198bb866bb6bc62ce))
* **impersonation:** revert this feature, sudoers is enough ([835783f](https://github.com/saltstack-formulas/airflow-formula/commit/835783ffc8ed3dd0910f1fd211d48c5e6fb67ac0))
* **initdb:** avoid fe_sendauth no password supplied ([7c6035f](https://github.com/saltstack-formulas/airflow-formula/commit/7c6035f272d5d24f709a152783afd88a0607606b))
* **pip:** apparently requests needs charset-normalizer ([082b0ec](https://github.com/saltstack-formulas/airflow-formula/commit/082b0ecdc4c270ee35ab904ebc6c77fa471b1ff1))
* **selinux:** add file contexts for home and systemd ([119d244](https://github.com/saltstack-formulas/airflow-formula/commit/119d24451eacf9be2c58221b0a143e658022a637))
* **services:** use pgpass for all services ([8614fe9](https://github.com/saltstack-formulas/airflow-formula/commit/8614fe96e70bddec6aede4ac4e068c220d233f27))
* **systemd:** correct permissions on service files ([570f63f](https://github.com/saltstack-formulas/airflow-formula/commit/570f63f77c5d9d308b379e5c0505d1872d9c1b23))
* **systemd:** restart systemd service on abnormal failure ([803994b](https://github.com/saltstack-formulas/airflow-formula/commit/803994b95bac59ade41da8df5a18446391b84e22))
* **virtualenv:** avoid bug where root owns __cache_ ([8b799f2](https://github.com/saltstack-formulas/airflow-formula/commit/8b799f27fd0128ff74acfa1f5ec737b4fb52c7fc))


### Code Refactoring

* **variable:** rename skip_users to create_user_group ([87dfbee](https://github.com/saltstack-formulas/airflow-formula/commit/87dfbeec93762887ebab3f1f968b7e4a1e74ab9e))


### Documentation

* **readme:** update readme (and revert impersonation) ([e81f515](https://github.com/saltstack-formulas/airflow-formula/commit/e81f51535e4666182fa1787bfe5ae7a5ecfec24c))
* **reamde:** udpated readme [skip ci] ([d8ce43c](https://github.com/saltstack-formulas/airflow-formula/commit/d8ce43c38e2bd6995933314a3517107cd2a52915))


### Features

* **firewall:** basic firewalld support ([8f94cc8](https://github.com/saltstack-formulas/airflow-formula/commit/8f94cc8b3f2c7e1c5fcefdb58c7439b6829680ae))
* **firewall:** basic zones support ([eb2a204](https://github.com/saltstack-formulas/airflow-formula/commit/eb2a2043cbf047cd7fa20d241e8e0da84cd3e9ee))
* **logfile:** support one custom format ([fcdc739](https://github.com/saltstack-formulas/airflow-formula/commit/fcdc73919205b8c9f792bd818751258e19d481b7))


### Tests

* **systemd:** expand inspec unit tests ([e48831b](https://github.com/saltstack-formulas/airflow-formula/commit/e48831b8d7be6e929fe30e3fa2d3319be9bdb274))
