# p2pbotnet

quick dirty edit to make notes: MUST RANK THEM IN ORDER OF IMPORTANCE
 - include dynamic code load  => generic code loader for multiplatform
     -VERY IMPORTANT ! define which section would be static and which section not
     -store a database of dynamic code to load when reboot 
     -maybe recompile itself as a whole (wow wow wow where are we going)
 - must be able to bootstrap easily ==> bootstrap server, by DNS, and in the cloud so takedown difficult. 
 - must be able to make push request when behind NAT !! **important**
 - include ranking system against freeloader
 - emiting ID must be controlled
 - admin node with static public/private key
 - blacklist IP AND/OR ID in the DHT (only from admin node)
 - include relaying, routing 
 - Connection time (polling command) fixed interval + random value to avoid time analysis detection
 - Make design modular enough tohave the visitor design patter implemented for each "action" of the bot:
 -       - authentication
 -       - message reception (for example, to evaluate if sender is honest or malicious)
 -       - message sending
 -       - "action" / "Command" 

-----------------------------
- hardcoded key so commands only available for admin .
- message between peers alawys encrypted
    => register for bootstrap server IP : PORT : PUBLIC KEY
    => connect to another peer with its public key 
    => then cipher key exchange
- admin is a peer itself
- every peer can send command but only admin peer will be executed
- p2p system like gnutella2 for the beginning. simpler.
- risks at the beginning : initial peer list. there should be already compromised devices or anonymously owned servers.
- BOOTSTRAP server in Tor!!!! 
- bootstreap server is also a peer in the p2p network that would be the "first" peer.
    => need only to get others addresses
    => if none,take the bootstrap server and change when new peers comes (limit Tor uses)
- if possible make the bots participate in Tor
- MONITORING => make every leaf node reports their info on hubs that aggregate + reports to the issuer                            


https://ccdcoe.org/cycon/2014/proceedings/d3r2s3_casenove.pdf
http://darkmatters.norsecorp.com/2014/12/15/tor-based-botnets-sure-why-not/
https://www.usenix.org/legacy/event/hotbots07/tech/full_papers/wang/wang_html/
http://cs.ucf.edu/~czou/research/P2PBotnets-bookChapter.pdf
    

MODULES:
    
    Bootstrap take care of bootstraping (no shit)
    Network take care of networking stuff ( + tor integration with Orchid)
    Peer take care of the logic of nodes communication
    Security take care of the security side of every actions taken by Peers (maybe in visitor design like with RubyNaCl) 
    Actions define the actions possible
    + OPTIONALS :
        Builder : let the bot rebuilds it self and evolving it self
        Infecter : let the bot infects other devices in its neighboorhood
        Stealth : let the bot detect if it is inpected or make stats about forged packets etc
    


##################
DONE : packets
TO_DO : make the network module => handles connections, parse into packets, packetbuffer if not enough data
        + LOGGING (do it now better than latter)
