- name: Auto Deploy
  run: |
    ssh root@${{ secrets.DO_SERVER_IP }} << 'EOF'
      cd /opt/blue-green-app/blue-green-deployment
      git pull origin main
      chmod +x scripts/*.sh
      ./scripts/switch.sh
    EOF