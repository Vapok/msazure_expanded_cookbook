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

action :get do
  if @current_resource.loaded
    converge_by("Get Disk from #{@new_resource}") do
      get_disk(@new_resource.diskname)
    end
  else
    converge_by("Create #{ @new_resource } List, Then Get Disk") do
      perform_list
      get_disk(@new_resource.diskname)  
    end
  end
end

def load_current_resource
  # Azure API Boilerplate
  @current_resource = Chef::Resource::MsazureExpandedVmDisks.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.management_certificate(@new_resource.management_certificate)
  @current_resource.subscription_id(@new_resource.subscription_id)
  @current_resource.management_endpoint(@new_resource.management_endpoint)
  
  # Attributes used for List Action
  @current_resource.list_of_disks(@new_resource.list_of_disks || Array.new) #output
  

  # Attributes used for Get Action
  @current_resource.diskname(@new_resource.diskname)
  @current_resource.diskinfo(@new_resource.diskinfo || Array.new) #output

  # Assign Attribute Accessors
  if disks_loaded?(@current_resource.list_of_disks)
    @current_resource.loaded = true
  else
    @current_resource.loaded = false
  end

  #Return Current Resource
  @current_resource
end

def get_disk(disk_name)
  disk = @new_resource.list_of_disks.select { |x| x.name == disk_name }
  if disk.count > 0
    diskinfo = Array.new
    diskinfo.push(disk.first)
    @new_resource.diskinfo(diskinfo)
  end
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