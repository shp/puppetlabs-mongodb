define mongodb::add_users(
  $db
  $users
)
{
  if defined($db){
    if !empty($users){
  
      include mongodb
  
      file {"/tmp/add_users.js":
        content => template('mongodb/add_users.js.erb'),
        owner => mongodb,
        group => mongodb,
        mode => 644,
        require => Service['mongodb']
      }
      
      exec {"add_users":
        command => "mongo ${db} /tmp/add_users.js",
        
      }
    
    }
    if !defined($users){fail("No users specified to be added the mongodb: ${db}")}
  }
  if !defined($db){fail("No db specified for adding users.")} 
}


