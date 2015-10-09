msazure_expanded Cookbook
=================================
This cookbook is a direct expansion of the microsoft_azure cookbook created by Jeff Mendoza (jemendoz@microsoft.com).
The microsoft_azure cookbook only provides for a couple Azure API services. The msazure_expanded cookbook adds additional services not accounted for in the original cookbook.

Requirements
------------
#### Cookbooks
- "microsoft_azure" cookbook ~>0.2.0


Attributes
----------

Usage
-----
Please refer to the "microsoft_azure" README file to understand how to use the resources provided in it, and the msazure_expanded

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Pete Navarra (@Vapok)


Recipes
=======

default.rb
----------

The default recipe installs the `azure` RubyGem, which this cookbook
requires in order to work with the Azure API. Make sure that the
microsoft_azure recipe is in the node or role `run_list` before any
resources from this cookbook are used.

    "run_list": [
      "recipe[msazure_expanded]"
    ]

The `gem_package` is created as a Ruby Object and thus installed
during the Compile Phase of the Chef run.

Resources and Providers
=======================

msazure_expanded_vm_images
--------------------------

## vm_images.rb


Loads available Azure VM Images with this resource into a resource attribute.

Actions:

* `init` - Initializes the Resource.

Attribute Parameters:

* `management_certificate` - PEM file contents of Azure management
  certificate, required.
* `subscription_id` - ID of Azure subscription, required.
* `management_endpoint` - Endpoint for Azure API, defaults to `management.core.windows.net`.
* `list_of_images` - List of available images loaded during Action Init

### Recipe Example
```
    msazure_expanded_vm_images 'images_listing' do
      management_certificate microsoft_azure['management_certificate'].join("\n")
      subscription_id microsoft_azure['subscription_id']
      action :init
    end
```
### Retrieving Output of Resource
```
    ruby_block 'show_images' do
      block do
          r = resources("msazure_expanded_vm_images[images_listing]")
          images = r.list_of_images
          if images.kind_of?(Array) && images.count > 0
            images.take(10).each do |image|
              puts "From Recipe: Image: #{image}"
            end
          else
            puts "Images not loaded?"
          end
      end
      action :run
    end
```