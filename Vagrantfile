Vagrant.configure("2") do |config|
  # Imagen base para las 4 máquinas: Debian 12 (Bookworm)
  config.vm.box = "debian/bookworm64"

  # =========================================================
  # CAPA 1 (Red Pública): Balanceador de Carga con Apache
  # =========================================================
  config.vm.define "AmparoSanchezBalanceador" do |balanceador|
    balanceador.vm.hostname = "AmparoSanchezBalanceador"
    
    # Subred 1 (conecta Capa 1 con Capa 2)
    balanceador.vm.network "private_network", ip: "192.168.56.10"
    
    # Reenvío de puertos para acceder desde el navegador del PC anfitrión (HTTP y HTTPS)
    balanceador.vm.network "forwarded_port", guest: 80, host: 8080
    balanceador.vm.network "forwarded_port", guest: 443, host: 8443
    
    # Script de aprovisionamiento del Balanceador
    balanceador.vm.provision "shell", path: "scripts/provision_balanceador.sh"
  end

  # =========================================================
  # CAPA 2 (Red Privada): Servidor Web 1 (Backend Web)
  # =========================================================
  config.vm.define "AmparoSanchezWeb1" do |web1|
    web1.vm.hostname = "AmparoSanchezWeb1"
    
    # Subred 1 (para recibir tráfico del Balanceador)
    web1.vm.network "private_network", ip: "192.168.56.11"
    # Subred 2 (para conectarse con la Base de Datos)
    web1.vm.network "private_network", ip: "192.168.57.11"
    
    # Script de aprovisionamiento Web
    web1.vm.provision "shell", path: "scripts/provision_web.sh"
  end

  # =========================================================
  # CAPA 2 (Red Privada): Servidor Web 2 (Backend Web)
  # =========================================================
  config.vm.define "AmparoSanchezWeb2" do |web2|
    web2.vm.hostname = "AmparoSanchezWeb2"
    
    # Subred 1 (para recibir tráfico del Balanceador)
    web2.vm.network "private_network", ip: "192.168.56.12"
    # Subred 2 (para conectarse con la Base de Datos)
    web2.vm.network "private_network", ip: "192.168.57.12"
    
    # Script de aprovisionamiento Web
    web2.vm.provision "shell", path: "scripts/provision_web.sh"
  end

  # =========================================================
  # CAPA 3 (Red Privada): Servidor de Base de Datos (BBDD)
  # =========================================================
  config.vm.define "AmparoSanchezBBDD" do |bbdd|
    bbdd.vm.hostname = "AmparoSanchezBBDD"
    
    # Subred 2 (aislada de la Capa 1, solo conecta con Web1 y Web2)
    bbdd.vm.network "private_network", ip: "192.168.57.20"
    
    # Script de aprovisionamiento de Base de Datos
    bbdd.vm.provision "shell", path: "scripts/provision_bbdd.sh"
  end
end