# mpox-yolov10

Implementation of **HOST-YOLOv10**, a customized YOLOv10-based framework for **automatic detection and clinical-stage classification of mpox (monkeypox) skin lesions**.  
The model is designed to discriminate the five clinically established stages of mpox lesion evolution—**macules, papules, vesicles, pustules, and scabs**—under real-world imaging conditions.

This repository provides:
- Training and evaluation scripts for HOST-YOLOv10
- Dataset handling and preprocessing utilities
- Quantitative evaluation using Precision–Recall analysis and confusion matrices
- Reproducible configuration files aligned with the reported experiments

The framework is oriented toward **clinical decision support**, prioritizing robustness, interpretability, and reliable performance across visually similar lesion stages.

---

## Table of Contents

1. [Overview](#overview)
2. [Model Architecture](#model-architecture)
3. [Dataset](#dataset)
4. [Installation](#installation)
5. [Training](#training)
6. [Evaluation](#evaluation)
7. [Results and Visualization](#results-and-visualization)
8. [Error Analysis and Clinical Interpretation](#error-analysis-and-clinical-interpretation)
9. [Reproducibility Notes](#reproducibility-notes)
10. [Citation](#citation)
11. [License](#license)

---

## Overview

Mpox skin lesions exhibit a **progressive morphological evolution**, where visually adjacent stages (e.g., papules vs. pustules or vesicles vs. pustules) can be difficult to distinguish, even for trained clinicians.  
Conventional object detectors trained on generic datasets often fail to capture these subtle circular and textural patterns.

**HOST-YOLOv10** addresses this challenge by introducing architectural refinements tailored to dermatological morphology, enabling:

- Accurate localization of lesions under heterogeneous acquisition conditions
- Robust discrimination between clinically adjacent stages
- Reduced inter-class confusion without sacrificing computational efficiency

---

## Model Architecture

HOST-YOLOv10 is built upon the YOLOv10 detection paradigm and incorporates three domain-driven enhancements:

1. **CBH-R (Circular Feature-Enhanced CBH Module)**  
   An extension of the standard CBH block that employs circular convolutional kernels to better capture rounded lesion contours typical of mpox lesions.

2. **GhostConv Layers**  
   Replace standard convolutions to reduce computational cost while preserving discriminative power, particularly beneficial for low-contrast and small lesions.

3. **NAM-R (Normalized Attention Module for Rounded Features)**  
   A morphology-aware attention mechanism that emphasizes smooth and circular structures, improving class separability between visually similar stages.

These components are integrated without disrupting the core YOLOv10 design principles, such as decoupled downsampling and efficient large-kernel usage.

---

## Dataset

The dataset comprises **clinically confirmed mpox cases only** and does not include historical smallpox (variola virus) images.

Key characteristics:

- Five lesion stages: macules, papules, vesicles, pustules, scabs
- Images collected from public health repositories and open research datasets
- Acquisition using heterogeneous devices (smartphones and digital cameras)
- High variability in resolution, illumination, viewpoint, background, and compression artifacts

All images are **fully anonymized**, and no patient-identifiable information is included.

To prevent data leakage, a strict **deduplication protocol** combining perceptual hashing and structural similarity was applied **before** dataset splitting.

---

## Installation

### Requirements

- Python ≥ 3.8
- PyTorch ≥ 2.0
- Ultralytics (YOLOv10)
- CUDA (optional, recommended)

### Setup

```bash
git clone https://github.com/Fernandoufop/mpox-yolov10.git
cd mpox-yolov10
pip install -r requirements.txt
