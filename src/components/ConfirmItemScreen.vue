<script>
import Stepper from "@/components/Stepper.vue";

export default {
  name: "ConfirmItemScreen",
  emits: ["goBack", "go-to-genstand-page"],
  components: {
    Stepper,
  },
  props: {
    currentStep: {
      type: Number,
      default: 1,
    },
    itemData: {
      type: Object,
      default: () => ({}),
    },
  },
  computed: {
    displayImage() {
      const images = this.itemData.images;
      return images && images.length ? images[0] : null;
    },
    fields() {
      const d = this.itemData;
      return [
        { label: "Navn", value: d.name || '—' },
        { label: "Mærke", value: d.brand || 'Intet mærke' },
        { label: "Kategori", value: d.category || '—' },
        { label: "Stand", value: d.condition || '—' },
        { label: "Antal", value: d.quantity || 1 },
        { label: "Minimum lejeperiode", value: d.minimumLoanPeriod ? `${d.minimumLoanPeriod} dage` : '1 dag' },
        { label: "Tilbehør", value: d.extras && d.extras.length ? d.extras.join(', ') : 'Intet tilbehør tilføjet' },
      ];
    },
  },
};
</script>

<template>
  <v-container class="pa-4">
      <!-- Top bar -->
      <v-toolbar flat color="white" class="top-toolbar">
        <!--  <v-btn icon variant="text" @click="$emit('goBack')">
          <v-icon>mdi-chevron-left</v-icon>
        </v-btn> -->

        <v-toolbar-title class="text-center font-weight-bold">
          Opret ny genstand
        </v-toolbar-title>

        <div style="width: 40px"></div>
      </v-toolbar>

      <v-divider />

      <!-- Stepper -->
      <Stepper :currentStep="currentStep" />

      <!-- Content -->
      <v-card-text class="px-5 pt-2 pb-8 text">
        <h2 class="text-h6 font-weight-bold mb-1">Tjek og bekræft</h2>
        <p class="text-body-2 text-medium-emphasis mb-5 text-body">
          Se hvordan din genstand vil se ud for andre. Du kan redigere alle
          felter direkte.
        </p>

        <!-- Images -->
        <div class="section-title mb-3">Billeder</div>

        <div class="image-row mb-5">
          <div class="image-preview" v-if="displayImage">
            <v-img
              :src="displayImage"
              cover
              width="72"
              height="72"
              class="rounded-lg"
            />
            <v-btn icon size="x-small" color="grey-darken-1" class="remove-btn">
              <v-icon size="14">mdi-close</v-icon>
            </v-btn>
          </div>

          <div class="add-image-box">
            <v-icon size="18" color="grey">mdi-camera-outline</v-icon>
            <span>Tilføj</span>
          </div>
        </div>

        <!-- Info cards -->
        <div class="info-list">
          <v-card
            v-for="field in fields"
            :key="field.label"
            variant="outlined"
            rounded="xl"
            class="mb-4 info-card"
          >
            <v-card-text class="d-flex justify-space-between align-start">
              <div>
                <div class="field-label mb-2">{{ field.label }}</div>
                <div class="field-value">{{ field.value }}</div>
              </div>

              <v-btn icon variant="text" size="small">
                <v-icon size="16" color="grey-darken-1"
                  >mdi-pencil-outline</v-icon
                >
              </v-btn>
            </v-card-text>
          </v-card>
        </div>
      </v-card-text>

      <!-- Bottom buttons -->
      <div class="bottom-bar">
        <v-btn
          variant="tonal"
          rounded="lg"
          color="grey-darken-2"
          class="back-button"
          @click="$emit('goBack')"
        >
          <v-icon start size="18">mdi-chevron-left</v-icon>
          Tilbage
        </v-btn>

        <v-btn
          color="primary"
          rounded="lg"
          class="create-button"
          @click="$emit('go-to-genstand-page')"
        >
          Opret genstand
        </v-btn>
      </div>
  </v-container>
</template>

<style scoped>
.preview-page {
  padding: 16px;
  background: #f5f5f5;
}

.preview-card {
  width: 100%;
  background: #fff;
  padding: 16px;
  border-radius: 12px;
  box-shadow: none;
  min-height: auto;
}

.top-toolbar {
  min-height: 56px;
}

.stepper-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px 8px;
  gap: 6px;
}

.step-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #6b7280;
}

.step-circle {
  width: 24px;
  height: 24px;
  border-radius: 999px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
}

.step-item.done .step-circle,
.step-item.active .step-circle {
  background: #389475;
  color: white;
}

.step-item.active span {
  color: #111827;
  font-weight: 600;
}

.step-line {
  flex: 1;
  height: 2px;
  min-width: 16px;
  background: #cfd8d3;
}

.step-line.done {
  background: #389475;
}

.section-title {
  font-size: 14px;
  font-weight: 600;
}

.image-row {
  display: flex;
  gap: 12px;
}

.image-preview {
  position: relative;
  width: 72px;
  height: 72px;
}

.remove-btn {
  position: absolute;
  top: -8px;
  right: -8px;
}

.add-image-box {
  width: 72px;
  height: 72px;
  border: 1px dashed #c9c9c9;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  color: #7a7a7a;
  font-size: 12px;
}

.info-card {
  background-color: #ffffff;
  border-color: #e5e7eb;
}

.info-list {
  padding-bottom: 96px;
}

.field-label {
  font-size: 12px;
  color: #6b7280;
}

.field-value {
  font-size: 15px;
  color: #111827;
  font-weight: 500;
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  border-top: 1px solid #e5e7eb;
  padding: 16px;
  display: flex;
  gap: 12px;

}

.back-button {
  flex: 1;
  text-transform: none;
  height: 48px !important;
}

.create-button {
  flex: 3;
  text-transform: none;
  height: 48px !important;
}
.text {
  font-family: "Roboto", sans-serif;
  color: #000000;
}
.text-body {
  font-family: "Roboto", sans-serif;
  color: grey;
}
</style>
