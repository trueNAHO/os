let
  hosts.masterplan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP6b528AWQ7b999cQIieawVqmd+6C/uEGVz4DuwAfqJo";
  publicKeys = [hosts.masterplan users.naho];
  users.naho = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrrgYSUQdMPznQBTYSr4jf1p9feRpVWjFuW1MdmtQM4";
in {
  "modules/networking/environmentFile.age".publicKeys = publicKeys;
  "modules/users/users/naho/passwordFile.age".publicKeys = publicKeys;
}
