include Azure::Cookbook

def whyrun_supported?
  true
end

action :list do
  if @current_resource.loaded
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource } List") do
      perform_list  
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::MsazureExpandedVmDisks.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.management_certificate(@new_resource.management_certificate)
  @current_resource.subscription_id(@new_resource.subscription_id)
  @current_resource.management_endpoint(@new_resource.management_endpoint)
  @current_resource.list_of_disks(@new_resource.list_of_disks || Array.new)
  @current_resource.diskinfo(@new_resource.diskinfo || Array.new)

  if disks_loaded?(@current_resource.list_of_disks)
    @current_resource.loaded = true
  else
    @current_resource.loaded = false
  end

  @current_resource
end

def fetch_disk_list(sms)
  sms.list_virtual_machine_disks.each { |vmdisk| @disks.push(vmdisk) }
  @disks.count > 0
end

def perform_list
  @disks = Array.new
  
  mc = setup_management_service

  sms = Azure::VirtualMachineImageManagement::VirtualMachineDiskManagementService.new
     
  if fetch_disk_list(sms)
    puts "\n\n       -  Azure VM Disk Count: #{@disks.count}"
    Chef::Log.info "[#{@new_resource}] #{@disks.count} Azure Disks Found"
  else
    puts "\n\n       -  *=*=*= No Azure VM Disks Found =*=*=*"
    Chef::Log.error "[#{@new_resource}] No Azure Disks Found"
  end
  @new_resource.list_of_disks(@disks)
  mc.unlink
end

def disks_loaded?(vmdisk)
  vmdisk.kind_of?(Array) && vmdisk.count > 0
end