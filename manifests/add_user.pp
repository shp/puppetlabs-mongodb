define mongodb::add_user(
  $username = $title,
  $password = undef,
  $database = undef,
  $roles = ["readWrite"],
)
{
  if $password == undef {
    fail("No password specified for adding user '${user}'.")
  }
  if $database == undef {
    fail("No database specified for adding user '${user}'.")
  }

  include mongodb
  
  # create two separate javascript files depending on whether this
  # version of mongod is using 2.4 or earlier
  # http://docs.mongodb.org/manual/release-notes/2.4/#security-improvements
  $script_dir = "/tmp"
  $filename_hash = md5("${username} ${database} ${password}")
  $filename_pre24 = "${script_dir}/add_user_pre2.4_${filename_hash}.js"
  file {"${filename_pre24}":
    ensure  => file,
    content => template('mongodb/add_user_pre2.4.js.erb'),
    mode    => 644,
    require => Service['mongodb'],
  }
  $filename_post24 = "${script_dir}/add_user_post2.4_${filename_hash}.js"
  file {"${filename_post24}":
    ensure  => file,
    content => template('mongodb/add_user_post2.4.js.erb'),
    mode    => 644,
    require => Service['mongodb'],
  }

  # render a script that detects which version of mongo is running at
  # run-time and then creates the user authentication in the right way
  # depending on whether mongo is pre-2.4 or post-2.4
  $script_filename = "${script_dir}/add_user_${filename_hash}.sh"
  file {"${script_filename}":
    ensure  => file,
    content => template('mongodb/add_user.sh.erb'),
    mode    => 744,
    require => Service['mongodb'],
  }

  # actually run the script the script to create the new users
  exec {"${script_filename}":
    logoutput => on_failure,
    path      => ["/sbin", "/usr/sbin", "/bin", "/usr/bin"],
    require   => [ File["${filename_pre24}"], File["${filename_post24}"],
                   File["${script_filename}"] ],
    unless    => "mongo -p${password} -u ${username} --eval 'db.system.users.find()' ${database}",
  }
  
}
