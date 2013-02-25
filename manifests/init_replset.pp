define mongodb::init_replset(
  $replSet,
  $members
)
{
  if defined($replSet){
    if !empty($members){
      
      include mongodb
      
      file {"init_replset.js":
        path    => '/tmp/init_replset.js',
        ensure  => file,
        content => template('mongodb/init_replset.js.erb'),
        owner   => mongodb,
        group   => mongodb,
        mode    => 644,
        require => Service['mongodb']
      }
      
      exec {"init_replset":
        command => "mongo /tmp/init_replset.js",
        require => File['init_replset.js']
      } 
       
    }
    if empty($members){fail("No members specified for replSet: ${replSet})}
  }
  if !defined($replSet){fail()}
}
