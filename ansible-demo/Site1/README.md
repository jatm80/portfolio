ansible-playbook -v --check --ask-vault-pass -i staging opensips.yml 
ansible-playbook -v --ask-vault-pass -i staging opensips.yml
ansible-playbook -v --check --ask-vault-pass -i staging asterisk.yml 
ansible-playbook -v --ask-vault-pass -i staging asterisk.yml
