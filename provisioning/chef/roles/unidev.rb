name "unidev"

run_list(
    "recipe[chef-solo-search]",
    "recipe[unidev::default]", 
    "recipe[unidev::python]",
    "recipe[unidev::cloud9]"
)