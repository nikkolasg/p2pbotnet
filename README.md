# p2pbotnet

quick dirty edit to make notes: MUST RANK THEM IN ORDER OF IMPORTANCE
 - include dynamic code load (DexClasssLoader for android) => generic code loader for multiplatform
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
