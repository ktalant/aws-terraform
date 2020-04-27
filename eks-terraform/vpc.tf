#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "talant_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "terraform-eks-demo-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "talant_subnet" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.talant_vpc.id
  map_public_ip_on_launch = true

  tags = map(
    "Name", "terraform-eks-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "talant_igw" {
  vpc_id = aws_vpc.talant_vpc.id

  tags = {
    Name = "terraform-eks-igw"
  }
}

resource "aws_route_table" "talant_rt" {
  vpc_id = aws_vpc.talant_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.talant_igw.id
  }
}

resource "aws_route_table_association" "talant_rt_association" {
  count = 2

  subnet_id      = aws_subnet.talant_subnet.*.id[count.index]
  route_table_id = aws_route_table.talant_rt.id
}
