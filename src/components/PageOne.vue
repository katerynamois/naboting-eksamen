<script>
import Stepper from "@/components/Stepper.vue";

export default {
  name: "PageOne",
  components: {
    Stepper,
  },
  props: {
    currentStep: {
      type: Number,
      default: 1,
    },
  },
  data() {
    return {
       selectedCategory: null,
    customCategory: "",
    uploadedImages: [],
    itemName: "",
    itemBrand: "",

    errors: {
      uploadedImages: "",
      selectedCategory: "",
      customCategory: "",
      itemName: "",
      }
    };
  },
  watch: {
    selectedCategory(newVal) {
      if (newVal !== "Andet") {
        this.customCategory = "";
      }
    },
  },
  methods: {
    openFileDialog() {
      this.$refs.fileInput.click();
    },
    readImageFile(file) {
      if (!file.type.startsWith("image/")) {
        this.errors.uploadedImages = "Kun billeder er tilladt";
        return;
      }
      if (file.size > 5 * 1024 * 1024) {
        this.errors.uploadedImages = "Billeder må ikke være større end 5MB";
        return;
      }
      const reader = new FileReader();
      reader.onload = (e) => {
        if (e.target && e.target.result) {
          this.uploadedImages.push(e.target.result);
          this.errors.uploadedImages = "";
        }
      };
      reader.onerror = () => {
        this.errors.uploadedImages = "Kunne ikke læse billedet. Prøv igen.";
      };
      reader.readAsDataURL(file);
    },
    handleFiles(event) {
      Array.from(event.target.files).forEach((file) => this.readImageFile(file));
    },
    handleDrop(event) {
      Array.from(event.dataTransfer.files).forEach((file) => this.readImageFile(file));
    },
    cancel() {
      this.$emit("go-back");
    },

     validate() {
  let valid = true;

  // Images
  if (this.uploadedImages.length === 0) {
    this.errors.uploadedImages = "Tilføj mindst ét billede";
    valid = false;
  } else {
    this.errors.uploadedImages = "";
  }

  // Category
  if (!this.selectedCategory) {
    this.errors.selectedCategory = "Vælg en kategori";
    valid = false;
  } else {
    this.errors.selectedCategory = "";
  }

  // Custom category
  if (this.selectedCategory === "Andet" && this.customCategory.trim() === "") {
    this.errors.customCategory = "Indtast en kategori";
    valid = false;
  } else {
    this.errors.customCategory = "";
  }

  // Item name
  if (!this.itemName.trim()) {
    this.errors.itemName = "Indtast et navn på din genstand";
    valid = false;
  } else {
    this.errors.itemName = "";
  }

  return valid;
},
      /*  Gem detaljer og gå videre til næste skridt */
    next() {
     if (this.validate()) {
    const data = {
      category:
        this.selectedCategory === "Andet"
          ? this.customCategory
          : this.selectedCategory,
      images: this.uploadedImages,
      name: this.itemName,
      brand: this.itemBrand.trim() || null,
    };

    this.$emit("go-to-add-details", data);
  }}
  },
};
</script>

<template>
  <v-container class="page-one-container pa-4" max-width="600">
    <v-toolbar flat color="white" class="top-toolbar">
      <!-- <v-btn icon variant="text" @click="$emit('goBack')">
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

    <h2>Beskriv din genstand</h2>
    <p>
      Tilføj billeder, vælg kategori og giv din genstand et navn, så andre kan
      finde den.
    </p>

    <div class="addPhoto">
      <h3>Billeder*</h3>
   
      <!-- Upload photo https://medium.com/swlh/drop-and-click-file-upload-with-vuetifyjs-f2c2a8357377 -->
      <v-card
        class="upload-card d-flex flex-column align-center justify-center text-center"
        @click="openFileDialog"
        @dragover.prevent
        @drop.prevent="handleDrop"
        flat
      >
        <div class="icon-wrapper mb-4">
          <v-icon size="32" color="var(--color-primary)">mdi-camera</v-icon>
        </div>

        <div class="text-h6 font-weight-bold mb-2">
          Tilføj mindst ét billede
        </div>

        <div class="text-body-2 text-medium-emphasis">
          Tryk for at uploade fotos af din genstand
        </div>

        <input
          type="file"
          ref="fileInput"
          multiple
          accept="image/*"
          style="display: none"
          @change="handleFiles"
        />
      </v-card>
<div v-if="errors.uploadedImages" class="error-text">
  {{ errors.uploadedImages }}
</div>
      <!-- Preview uploaded images -->
      <div class="uploaded-images mt-4" v-if="uploadedImages.length">
        <v-img
          v-for="(img, index) in uploadedImages"
          :key="index"
          :src="img"
          max-width="150"
          class="mr-4 mb-4"
          rounded
        />
      </div>
    </div>

    <!-- Category selection -->
    <div>
      <h3>Kategori*</h3>
       <div v-if="errors.selectedCategory" class="error-text">
         {{ errors.selectedCategory }}
        </div>
      <v-btn-toggle
        v-model="selectedCategory"
        class="category-toggle d-flex flex-wrap ga-2"
        mandatory
      >
        <v-btn value="Elektronik" rounded="xl" variant="tonal"
          >Elektronik</v-btn
        >
        <v-btn value="Værktøj" rounded="xl" variant="tonal">Værktøj</v-btn>
        <v-btn value="Sport" rounded="xl" variant="tonal">Sport</v-btn>
        <v-btn value="Køkken" rounded="xl" variant="tonal">Køkken</v-btn>
        <v-btn value="Haveredskaber" rounded="xl" variant="tonal"
          >Haveredskaber</v-btn
        >
        <v-btn value="Andet" rounded="xl" variant="tonal">Andet</v-btn>
      </v-btn-toggle>
      

      <v-text-field
        v-if="selectedCategory === 'Andet'"
        v-model="customCategory"
        label="Skriv din kategori"
        class="mt-4"
        color="var(--color-primary)"
        variant="outlined"
        rounded="xl"
        clearable
      />
      <div v-if="errors.customCategory" class="error-text">
  {{ errors.customCategory }}
</div>
     

      <h3>Navn på genstand*</h3>
      <div v-if="errors.itemName" class="error-text">
  {{ errors.itemName }}
</div>
      <v-text-field
        v-model="itemName"
        label="Hvad er det for en genstand?"
        class="mt-4"
        color="var(--color-primary)"
        variant="outlined"
        rounded="xl"
      />

      <h3>Mærke</h3>
      <v-text-field
        v-model="itemBrand"
        label="F.eks. Bosch, Apple..."
        class="mt-4"
        color="var(--color-primary)"
        variant="outlined"
        rounded="xl"
      />
    </div>

    <!--  Tilbage og næste knapper -->

    <div class="bottom-bar">
      <v-btn
        variant="tonal"
        rounded="lg"
        color="grey-darken-2"
        class="back-button"
        @click="cancel"
      >
        <v-icon start size="18">mdi-chevron-left</v-icon>
        Tilbage
      </v-btn>

      <v-btn color="primary" rounded="lg" class="create-button" @click="next">
        Næste
      </v-btn>
    </div>
  </v-container>
</template>

<style scoped>
.page-one-container {
  min-height: 100vh;
  padding-bottom: calc(120px + env(safe-area-inset-bottom)) !important;
}

.category-toggle .v-btn--active {
  background-color: var(--color-primary) !important;
  color: white !important;
}

.category-toggle .v-btn {
  height: 36px !important;
  min-width: unset !important;
  padding: 0 12px !important;
}
.category-toggle {
  flex-wrap: wrap !important;
  height: auto !important;
}

.uploaded-images {
  display: flex;
  flex-wrap: wrap;
}
:deep(.v-field) {
  --v-field-border-width: 3px;
  background-color: #ffffff;
}

.upload-card {
  height: 240px;
  border: 2px dashed var(--color-primary);
  border-radius: var(--radius-lg);
  background-color: var(--color-image-bg);
  cursor: pointer;
  transition: all 0.2s ease;
}

.upload-card:hover {
  background-color: #E8F0E3;
  border-color: var(--color-primary-dark);
}

/* Icon background */
.icon-wrapper {
  background-color: #E8F0E3;
  border-radius: 20px;
  padding: 16px;
}

.fixed-bottom-buttons {
  position: fixed;
  bottom: 0;
  left: 0;
  width: 100%;
  display: flex;
  justify-content: center;
  gap: 2px;
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

.error-text {
  color: red;
  font-size: 14px;
  margin-top: 4px;
}
</style>
