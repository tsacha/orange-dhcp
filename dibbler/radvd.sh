#!/bin/bash
if [ $SRV_MESSAGE = "REPLY" ]
then
    LAN=local
    WAN=data
    LXC=lxcbr0
    taille=${#PREFIX1}
    taille=$((taille-4))

    cat > /etc/radvd.conf << EOF
interface ${LAN}
{ 
     AdvSendAdvert on; 
     prefix ${PREFIX1:0:taille}10::/64
     { 

         AdvOnLink on;
         AdvPreferredLifetime 86400;
         AdvValidLifetime 86400;
         AdvAutonomous on;
   	 AdvRouterAddr on;
     };
RDNSS ${PREFIX1:0:taille}10::1
        {
                AdvRDNSSLifetime 600;
        };
};
interface ${LXC}
{ 
     AdvSendAdvert on; 
     prefix ${PREFIX1:0:taille}20::/64
     { 

         AdvOnLink on;
         AdvPreferredLifetime 86400;
         AdvValidLifetime 86400;
         AdvAutonomous on;
   	 AdvRouterAddr on;
     };
RDNSS ${PREFIX1:0:taille}20::1
        {
                AdvRDNSSLifetime 600;
        };
};
EOF


    /opt/flushv6 ${WAN}
    /opt/flushv6 ${LAN}
    /opt/flushv6 ${LXC}

    ip -6 route add fe80::ba0:bab dev ${WAN}
    ip -6 route add default via fe80::ba0:bab dev ${WAN}
    ip -6 route add ${PREFIX1:0:taille}10::/64 dev ${LAN}
    ip -6 addr add ${PREFIX1:0:taille}10::1/64 dev ${LAN}
    ip -6 route add ${PREFIX1:0:taille}20::/64 dev ${LXC}
    ip -6 addr add ${PREFIX1:0:taille}20::1/64 dev ${LXC}    
    ip -6 addr add $PREFIX1/56 dev ${WAN}
    systemctl restart radvd
    echo $PREFIX1 > /opt/prefix6

else
    echo "Warning error" > /etc/dibbler/radvd.cfg
fi
