#include <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define TABLE_SIZE 256

// Helper: Hex Color Calculation
// We blend "White" (1.0, 1.0, 1.0) with the Target Color based on intensity.
// Intensity 0.0 = Pure White (No change)
// Intensity 1.0 = Target Color (Full Tint)
void calculate_tint(float r_target, float g_target, float b_target,
                    float intensity, float *r_scale, float *g_scale,
                    float *b_scale) {
  *r_scale = 1.0f * (1.0f - intensity) + r_target * intensity;
  *g_scale = 1.0f * (1.0f - intensity) + g_target * intensity;
  *b_scale = 1.0f * (1.0f - intensity) + b_target * intensity;
}

int set_gamma(char *mode_name) {
  CGDirectDisplayID display = CGMainDisplayID();
  CGGammaValue red[TABLE_SIZE], green[TABLE_SIZE], blue[TABLE_SIZE];

  // Base Scalers (Default 1.0 = Normal)
  float rs = 1.0, gs = 1.0, bs = 1.0;

  if (strcmp(mode_name, "normal") == 0) {
    // Keep 1.0
    printf("Gamma: Restoring Normal\n");
  } else if (strcmp(mode_name, "red") == 0) {
    // Reflective Mode: Target #b22222 (Firebrick)
    // R=178/255=0.69, G=34/255=0.13, B=34/255=0.13
    // Intensity: 0.3 (Subtle Red Tint)
    printf("Gamma: Applying RED TINT (Reflective #b22222)\n");
    calculate_tint(0.70f, 0.13f, 0.13f, 0.30f, &rs, &gs, &bs);
  } else if (strcmp(mode_name, "blue") == 0) {
    // Execution Mode: Target #007fff (Azure Radiance)
    // R=0, G=127/255=0.5, B=255/255=1.0
    // Intensity: 0.25 (Subtle Blue Tint)
    printf("Gamma: Applying BLUE TINT (Execution #007fff)\n");
    calculate_tint(0.0f, 0.5f, 1.0f, 0.25f, &rs, &gs, &bs);
  } else if (strcmp(mode_name, "sepia") == 0) {
    // Creative Mode: Target #f5deb3 (Wheat)
    // R=245/255=0.96, G=222/255=0.87, B=179/255=0.70
    // Intensity: 0.5 (Medium Warmth)
    printf("Gamma: Applying SEPIA TINT (Creative #f5deb3)\n");
    calculate_tint(0.96f, 0.87f, 0.70f, 0.50f, &rs, &gs, &bs);
  } else if (strcmp(mode_name, "dim") == 0 ||
             strcmp(mode_name, "grayscale") == 0) {
    // DIM Mode (for Minimal)
    printf("Gamma: Applying DIM (Low Brightness)\n");
    rs = 0.7f;
    gs = 0.7f;
    bs = 0.7f;
  } else {
    printf("Unknown gamma mode: %s\n", mode_name);
    return 1;
  }

  // Generate Tables
  for (int i = 0; i < TABLE_SIZE; i++) {
    float val = (float)i / (float)(TABLE_SIZE - 1);
    red[i] = val * rs;
    green[i] = val * gs;
    blue[i] = val * bs;
  }

  CGError err =
      CGSetDisplayTransferByTable(display, TABLE_SIZE, red, green, blue);
  if (err != kCGErrorSuccess) {
    printf("Error setting gamma: %d\n", err);
    return 1;
  }

  // Persist
  if (strcmp(mode_name, "normal") != 0) {
    printf("Gamma set. Running in background. (Ctrl+C to stop)\n");
    while (1)
      sleep(10);
  }
  return 0;
}

// --- Helper: Set Resolution ---
int set_resolution(int targetParam1, int targetParam2) {
  CGDirectDisplayID display = CGMainDisplayID();

  if (targetParam1 == 0 && targetParam2 == 0) {
    printf("Resetting to Native/Default is complex in CLI. Use explicit "
           "numbers.\n");
    return 1;
  }

  int targetW = targetParam1;
  int targetH = targetParam2;

  printf("Resolution: Searching for %d x %d...\n", targetW, targetH);

  CFArrayRef modeList = CGDisplayCopyAllDisplayModes(display, NULL);
  CFIndex count = CFArrayGetCount(modeList);
  CGDisplayModeRef targetMode = NULL;

  for (CFIndex i = 0; i < count; i++) {
    CGDisplayModeRef mode =
        (CGDisplayModeRef)CFArrayGetValueAtIndex(modeList, i);
    if (CGDisplayModeGetWidth(mode) == (size_t)targetW &&
        CGDisplayModeGetHeight(mode) == (size_t)targetH) {
      targetMode = mode;
      break;
    }
  }

  if (targetMode) {
    CGDisplayConfigRef config;
    CGBeginDisplayConfiguration(&config);
    CGConfigureDisplayWithDisplayMode(config, display, targetMode, NULL);
    CGError err =
        CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
    if (err == kCGErrorSuccess) {
      printf("✓ Resolution set to %dx%d\n", targetW, targetH);
    } else {
      printf("Error applying resolution: %d\n", err);
      CFRelease(modeList);
      return 1;
    }
  } else {
    printf("Error: Resolution %dx%d not supported.\n", targetW, targetH);
    CFRelease(modeList);
    return 1;
  }

  CFRelease(modeList);
  return 0;
}

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("Usage: %s gamma [mode] OR %s res [w] [h]\n", argv[0], argv[0]);
    return 1;
  }

  char *command = argv[1];

  if (strcmp(command, "gamma") == 0) {
    if (argc < 3)
      return 1;
    return set_gamma(argv[2]);
  } else if (strcmp(command, "res") == 0) {
    if (argc < 4)
      return 1;
    return set_resolution(atoi(argv[2]), atoi(argv[3]));
  } else {
    printf("Unknown command: %s\n", command);
    return 1;
  }
  return 0;
}
