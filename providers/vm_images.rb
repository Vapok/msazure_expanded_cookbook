include Azure::Cookbook

def whyrun_supported?
  true
end

action :init do
  if @current_resource.loaded
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      perform_init  
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::MsazureExpandedVmImages.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.management_certificate(@new_resource.management_certificate)
  @current_resource.subscription_id(@new_resource.subscription_id)
  @current_resource.management_endpoint(@new_resource.management_endpoint)
  @current_resource.list_of_images(@new_resource.list_of_images || Array.new)

  if images_loaded?(@current_resource.list_of_images)
    @current_resource.loaded = true
  else
    @current_resource.loaded = false
  end

  @current_resource
end

def fetch_image_list(sms)
  sms.list_virtual_machine_images.each { |vmimage| @images.push(vmimage.name) }
  @images.count > 0
end

def perform_init
 @images = Array.new
  
  mc = setup_management_service

  sms = Azure::VirtualMachineImageManagementService.new
     
  if fetch_image_list(sms)
    puts "\n\n\n       -  Azure VM Image Count: #{@images.count}"
  else
    puts "\n\n\n       -  =*=*=*= No Azure VM Images Found =*=*=*="
  end
  @new_resource.list_of_images(@images)
  mc.unlink
end

def images_loaded?(images)
  images.kind_of?(Array) && images.count > 0
end