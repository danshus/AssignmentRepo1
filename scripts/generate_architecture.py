#!/usr/bin/env python3
"""
Sentinel Architecture Diagram Generator
Generates a comprehensive architecture diagram as PDF
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import numpy as np
from datetime import datetime
import os

def create_architecture_diagram():
    """Create the Sentinel architecture diagram"""
    
    # Create figure and axis
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Colors
    colors = {
        'internet': '#FF6B6B',
        'gateway_vpc': '#4ECDC4',
        'backend_vpc': '#45B7D1',
        'eks': '#96CEB4',
        'security': '#FFEAA7',
        'network': '#DDA0DD',
        'loadbalancer': '#FFB347',
        'nat': '#98D8C8'
    }
    
    # Title
    ax.text(8, 11.5, 'Sentinel - Secure Multi-VPC Architecture', 
            fontsize=20, fontweight='bold', ha='center')
    ax.text(8, 11.2, 'DevSecOps Technical Challenge Implementation', 
            fontsize=14, ha='center', style='italic')
    
    # Internet
    internet = FancyBboxPatch((0.5, 10), 15, 0.8, 
                             boxstyle="round,pad=0.1", 
                             facecolor=colors['internet'], 
                             edgecolor='black', linewidth=2)
    ax.add_patch(internet)
    ax.text(8, 10.4, 'Internet', fontsize=16, fontweight='bold', ha='center')
    
    # Gateway VPC
    gateway_vpc = FancyBboxPatch((0.5, 5.5), 7, 4, 
                                boxstyle="round,pad=0.1", 
                                facecolor=colors['gateway_vpc'], 
                                edgecolor='black', linewidth=2)
    ax.add_patch(gateway_vpc)
    ax.text(4, 9.2, 'Gateway VPC (10.0.0.0/16)', fontsize=14, fontweight='bold', ha='center')
    
    # Backend VPC
    backend_vpc = FancyBboxPatch((8.5, 5.5), 7, 4, 
                                boxstyle="round,pad=0.1", 
                                facecolor=colors['backend_vpc'], 
                                edgecolor='black', linewidth=2)
    ax.add_patch(backend_vpc)
    ax.text(12, 9.2, 'Backend VPC (10.1.0.0/16)', fontsize=14, fontweight='bold', ha='center')
    
    # VPC Peering Connection
    peering = ConnectionPatch((7.5, 7.5), (8.5, 7.5), "data", "data",
                            arrowstyle="<->", shrinkA=5, shrinkB=5,
                            mutation_scale=20, fc=colors['network'], 
                            linewidth=3, linestyle='--')
    ax.add_patch(peering)
    ax.text(8, 7.8, 'VPC Peering', fontsize=10, ha='center', 
            bbox=dict(boxstyle="round,pad=0.3", facecolor='white', alpha=0.8))
    
    # Gateway VPC Components
    
    # Load Balancer
    lb = FancyBboxPatch((1, 8.5), 2, 0.6, 
                       boxstyle="round,pad=0.05", 
                       facecolor=colors['loadbalancer'], 
                       edgecolor='black', linewidth=1)
    ax.add_patch(lb)
    ax.text(2, 8.8, 'ALB\n(Public)', fontsize=9, ha='center', fontweight='bold')
    
    # Gateway EKS Cluster
    gateway_eks = FancyBboxPatch((1, 6.5), 2, 1.5, 
                                boxstyle="round,pad=0.05", 
                                facecolor=colors['eks'], 
                                edgecolor='black', linewidth=1)
    ax.add_patch(gateway_eks)
    ax.text(2, 7.25, 'EKS Gateway\nCluster', fontsize=9, ha='center', fontweight='bold')
    
    # Gateway Proxy Service
    proxy = FancyBboxPatch((1, 5.8), 2, 0.5, 
                          boxstyle="round,pad=0.05", 
                          facecolor=colors['security'], 
                          edgecolor='black', linewidth=1)
    ax.add_patch(proxy)
    ax.text(2, 6.05, 'Proxy Service', fontsize=8, ha='center')
    
    # Gateway Private Subnets
    subnet1 = FancyBboxPatch((4, 7.5), 2.5, 1, 
                            boxstyle="round,pad=0.05", 
                            facecolor=colors['network'], 
                            edgecolor='black', linewidth=1)
    ax.add_patch(subnet1)
    ax.text(5.25, 8, 'Private Subnet\nAZ-A (10.0.1.0/24)', fontsize=8, ha='center')
    
    subnet2 = FancyBboxPatch((4, 6), 2.5, 1, 
                            boxstyle="round,pad=0.05", 
                            facecolor=colors['network'], 
                            edgecolor='black', linewidth=1)
    ax.add_patch(subnet2)
    ax.text(5.25, 6.5, 'Private Subnet\nAZ-B (10.0.2.0/24)', fontsize=8, ha='center')
    
    # NAT Gateways
    nat1 = FancyBboxPatch((4, 8.8), 1, 0.4, 
                         boxstyle="round,pad=0.05", 
                         facecolor=colors['nat'], 
                         edgecolor='black', linewidth=1)
    ax.add_patch(nat1)
    ax.text(4.5, 9, 'NAT\nGateway', fontsize=7, ha='center')
    
    # Backend VPC Components
    
    # Backend EKS Cluster
    backend_eks = FancyBboxPatch((9.5, 6.5), 2, 1.5, 
                                boxstyle="round,pad=0.05", 
                                facecolor=colors['eks'], 
                                edgecolor='black', linewidth=1)
    ax.add_patch(backend_eks)
    ax.text(10.5, 7.25, 'EKS Backend\nCluster', fontsize=9, ha='center', fontweight='bold')
    
    # Backend Service
    backend_svc = FancyBboxPatch((9.5, 5.8), 2, 0.5, 
                                boxstyle="round,pad=0.05", 
                                facecolor=colors['security'], 
                                edgecolor='black', linewidth=1)
    ax.add_patch(backend_svc)
    ax.text(10.5, 6.05, 'Backend Service', fontsize=8, ha='center')
    
    # Backend Private Subnets
    backend_subnet1 = FancyBboxPatch((12, 7.5), 2.5, 1, 
                                    boxstyle="round,pad=0.05", 
                                    facecolor=colors['network'], 
                                    edgecolor='black', linewidth=1)
    ax.add_patch(backend_subnet1)
    ax.text(13.25, 8, 'Private Subnet\nAZ-A (10.1.1.0/24)', fontsize=8, ha='center')
    
    backend_subnet2 = FancyBboxPatch((12, 6), 2.5, 1, 
                                    boxstyle="round,pad=0.05", 
                                    facecolor=colors['network'], 
                                    edgecolor='black', linewidth=1)
    ax.add_patch(backend_subnet2)
    ax.text(13.25, 6.5, 'Private Subnet\nAZ-B (10.1.2.0/24)', fontsize=8, ha='center')
    
    # Backend NAT Gateway
    backend_nat = FancyBboxPatch((12, 8.8), 1, 0.4, 
                                boxstyle="round,pad=0.05", 
                                facecolor=colors['nat'], 
                                edgecolor='black', linewidth=1)
    ax.add_patch(backend_nat)
    ax.text(12.5, 9, 'NAT\nGateway', fontsize=7, ha='center')
    
    # Security Components
    
    # Security Groups
    sg_gateway = FancyBboxPatch((0.2, 4.5), 3, 0.8, 
                               boxstyle="round,pad=0.05", 
                               facecolor=colors['security'], 
                               edgecolor='black', linewidth=1)
    ax.add_patch(sg_gateway)
    ax.text(1.7, 4.9, 'Security Groups\n(Gateway)', fontsize=8, ha='center')
    
    sg_backend = FancyBboxPatch((12.8, 4.5), 3, 0.8, 
                               boxstyle="round,pad=0.05", 
                               facecolor=colors['security'], 
                               edgecolor='black', linewidth=1)
    ax.add_patch(sg_backend)
    ax.text(14.3, 4.9, 'Security Groups\n(Backend)', fontsize=8, ha='center')
    
    # Network Policies
    np_gateway = FancyBboxPatch((4.2, 4.5), 3, 0.8, 
                               boxstyle="round,pad=0.05", 
                               facecolor=colors['security'], 
                               edgecolor='black', linewidth=1)
    ax.add_patch(np_gateway)
    ax.text(5.7, 4.9, 'Network Policies\n(Gateway)', fontsize=8, ha='center')
    
    np_backend = FancyBboxPatch((8.8, 4.5), 3, 0.8, 
                               boxstyle="round,pad=0.05", 
                               facecolor=colors['security'], 
                               edgecolor='black', linewidth=1)
    ax.add_patch(np_backend)
    ax.text(10.3, 4.9, 'Network Policies\n(Backend)', fontsize=8, ha='center')
    
    # CI/CD Pipeline
    cicd = FancyBboxPatch((6, 3), 4, 1, 
                         boxstyle="round,pad=0.1", 
                         facecolor='#FFD93D', 
                         edgecolor='black', linewidth=2)
    ax.add_patch(cicd)
    ax.text(8, 3.5, 'GitHub Actions CI/CD Pipeline', fontsize=12, fontweight='bold', ha='center')
    
    # CI/CD Components
    ax.text(6.5, 3.2, '• Terraform Validation', fontsize=9, ha='left')
    ax.text(6.5, 3.0, '• Security Scanning (Trivy)', fontsize=9, ha='left')
    ax.text(6.5, 2.8, '• Infrastructure Deployment', fontsize=9, ha='left')
    ax.text(9.5, 3.2, '• K8s Manifest Validation', fontsize=9, ha='left')
    ax.text(9.5, 3.0, '• Application Deployment', fontsize=9, ha='left')
    ax.text(9.5, 2.8, '• OIDC Federation', fontsize=9, ha='left')
    
    # Data Flow Arrows
    
    # Internet to ALB
    arrow1 = ConnectionPatch((2, 10), (2, 9.1), "data", "data",
                           arrowstyle="->", shrinkA=5, shrinkB=5,
                           mutation_scale=15, fc='black', linewidth=2)
    ax.add_patch(arrow1)
    ax.text(2.5, 9.6, 'HTTPS', fontsize=8, ha='left')
    
    # ALB to Gateway EKS
    arrow2 = ConnectionPatch((2, 8.5), (2, 8), "data", "data",
                           arrowstyle="->", shrinkA=5, shrinkB=5,
                           mutation_scale=15, fc='black', linewidth=2)
    ax.add_patch(arrow2)
    ax.text(2.5, 8.25, 'HTTP', fontsize=8, ha='left')
    
    # Gateway to Backend
    arrow3 = ConnectionPatch((3, 7.25), (8.5, 7.25), "data", "data",
                           arrowstyle="->", shrinkA=5, shrinkB=5,
                           mutation_scale=15, fc='black', linewidth=2)
    ax.add_patch(arrow3)
    ax.text(5.75, 7.5, 'HTTP (VPC Peering)', fontsize=8, ha='center')
    
    # Legend
    legend_elements = [
        patches.Patch(color=colors['internet'], label='Internet'),
        patches.Patch(color=colors['gateway_vpc'], label='Gateway VPC'),
        patches.Patch(color=colors['backend_vpc'], label='Backend VPC'),
        patches.Patch(color=colors['eks'], label='EKS Clusters'),
        patches.Patch(color=colors['security'], label='Security Components'),
        patches.Patch(color=colors['network'], label='Network Components'),
        patches.Patch(color=colors['loadbalancer'], label='Load Balancer'),
        patches.Patch(color=colors['nat'], label='NAT Gateway')
    ]
    
    ax.legend(handles=legend_elements, loc='upper left', bbox_to_anchor=(0, 0.3))
    
    # Security Features
    security_text = """Security Features:
• Private Subnets Only
• VPC Peering with Route Control
• Security Groups (Granular Access)
• Network Policies (Pod-level Security)
• OIDC Federation (No Long-lived Credentials)
• Infrastructure as Code (Auditable)
• Automated Security Scanning
• Multi-AZ High Availability"""
    
    ax.text(0.5, 1.5, security_text, fontsize=10, 
            bbox=dict(boxstyle="round,pad=0.5", facecolor='lightgray', alpha=0.8))
    
    # Footer
    ax.text(8, 0.5, f'Generated on {datetime.now().strftime("%Y-%m-%d %H:%M:%S")} | Sentinel DevSecOps Challenge', 
            fontsize=10, ha='center', style='italic')
    
    return fig

def main():
    """Main function to generate and save the architecture diagram"""
    print("🔧 Generating Sentinel architecture diagram...")
    
    # Create the diagram
    fig = create_architecture_diagram()
    
    # Ensure output directory exists
    output_dir = "docs"
    os.makedirs(output_dir, exist_ok=True)
    
    # Save as PDF
    output_file = os.path.join(output_dir, "sentinel_architecture.pdf")
    fig.savefig(output_file, format='pdf', dpi=300, bbox_inches='tight')
    
    print(f"✅ Architecture diagram saved to: {output_file}")
    
    # Also save as PNG for easier viewing
    png_file = os.path.join(output_dir, "sentinel_architecture.png")
    fig.savefig(png_file, format='png', dpi=300, bbox_inches='tight')
    
    print(f"✅ Architecture diagram also saved as PNG: {png_file}")
    
    plt.close(fig)
    
    print("🎉 Architecture diagram generation completed!")

if __name__ == "__main__":
    main() 