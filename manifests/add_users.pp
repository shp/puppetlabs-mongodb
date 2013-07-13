define mongodb::add_users(
  $db = $title,
  $users
)
{
  if $db == undef {fail("No db specified for adding users.")}
  if !empty($users){

    include mongodb

    $filename = "add_${db}_users.js"
    file {"${filename}":
      path    => "/tmp/${filename}",
      ensure  => file,
      content => template('mongodb/add_users.js.erb'),
      owner   => mongodb,
      group   => mongodb,
      mode    => 644,
      require => Service['mongodb']
    }
    
    exec {"add_users":
      command => "mongo ${db} /tmp/${filename}",
      require => File["${filename}"]
    }

  }
  if empty($users){fail("No users specified to be added to ${db}")}
}
