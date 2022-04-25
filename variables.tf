variable "enviro" {
  type        = string
  description = "define the environment ex. dev,tst,prd,stg"
  default     = "dev"
}

variable "prjnum" {
  type        = string
  description = "define the project number for TFstate file ex. 4858"
  default     = "1111"
}

variable "location" {
  type        = string
  description = "location of your resource group"
  default     = "usgovvirginia"
}

variable "orgname" {
  type        = string
  default     = "tcld"
}

variable "vnet_hub_address_spaces" {
  type        = list
  default     = ["192.168.145.0/24"]
}
variable "vnet_hub_dns_servers" {
  type        = list
  default     = ["8.8.8.8", "1.1.1.1"]
}
variable "azfw_subnet_prefixes" {
  type        = list
  default     = ["192.168.145.0/26"]
}
variable "bastion_subnet_prefixes" {
  type        = list
  default     = ["192.168.145.64/26"]
}
variable "gateway_subnet_prefixes" {
  type        = list
  default     = ["192.168.145.128/27"]
}

variable "vm_subnet_prefixes" {
  type        = list
  default     = ["192.168.145.160/27"]
}

variable "resourcegroupnames" {
  type = list
  default = ["Connectivity", "NetSec", "Security", "MGMT"]
}

variable "web_categories_blacklist" {
  type    = list(any)
  default = ["ChildAbuseImages", "CriminalActivity", "Cults", "Gambling", "HateAndIntolerance", "IllegalDrug", "IllegalSoftware", "LingerieAndSwimsuits", "Nudity", "PornographyAndSexuallyExplicit", "SelfHarm", "Uncategorized", "Violence"]

  description = "list which can included any of the following" #example all categories: ["AdvertisementsAndPopUps", "AlcoholAndTobacco", "Arts", "Business", "Chat", "ChildAbuseImages", "ChildInappropriate", "ComputersAndTechnology", "CriminalActivity", "Cults", "DatingAndPersonals", "DownloadSites", "Education", "Entertainment", "Finance", "ForumsAndNewsgroups", "Gambling", "Games", "General", "Government", "GreetingCards", "Hacking", "HateAndIntolerance", "HealthAndMedicine", "IllegalDrug", "IllegalSoftware", "ImageSharing", "InformationSecurity", "InstantMessaging", "JobSearch", "LeisureAndRecreation", "LingerieAndSwimsuits", "Marijuana", "NatureAndConservation", "News", "NonProfitsAndNgos", "Nudity", "PeerToPeer", "PersonalSites", "PornographyAndSexuallyExplicit", "PrivateIPAddresses", "ProfessionalNetworking", "RealEstate", "Religion", "RestaurantsAndDining", "SchoolCheating", "SearchEnginesAndPortals", "SelfHarm", "SexEducation", "Shopping", "SocialNetworking", "Sports", "StreamingMediaAndDownloads", "Tasteless", "Translators", "Transportation", "Travel", "Uncategorized", "Violence", "Weapons", "WebBasedEmail", "WebRepositoryAndStorage"]
}

variable "fqdnblacklist" {
  type    = list(any)
  default = ["yahoo.com", "ipchicken.com", "kiloroot.com", "*.yahoo.com", "*.ipchicken.com", "*.kiloroot.com"]
}