define mongodb::add_users(
  $db,
  $users
)
{
  if defined($db){
    if !empty($users){
  
      include mongodb
  
      file {"add_users.js":
        path => '/tmp/add_users.js',
        ensure  => file,
        content => template('mongodb/add_users.js.erb'),
        owner   => mongodb,
        group   => mongodb,
        mode    => 644,
        require => Service['mongodb']
      }
      
      exec {"add_users":
        command => "mongo ${db} /tmp/add_users.js",
        require => File['add_users.js']
      }
    
    }
    if empty($users){fail("No users specified to be added to ${db}")}
  }
  if !defined($db){fail("No db specified for adding users.")} 
}


