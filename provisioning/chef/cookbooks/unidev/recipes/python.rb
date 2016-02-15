#
# Cookbook Name:: devbox
# Recipe:: python
#
# Apache Public License 

include_recipe "python"

pips = [
    "awscli"
]

pips.each do |p|
    python_pip p do
        action :install
    end
end