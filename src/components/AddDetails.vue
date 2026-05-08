<script>
import Stepper from "@/components/Stepper.vue";


export default {
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
      hasExtra: null,
      extrasList: [],
      extraName: "",
      condition: null,
      quantity: 1,
      minimumLoanPeriod: 1,
      errors: {
        hasExtra: "", 
        extrasList: "",
        condition: "",
      }
    };
  },
  methods: {
    /* Vælg om der er ekstra tilbehør eller ej */
    selectExtra(value) {
      this.hasExtra = value;
      this.errors.hasExtra = "";
    },
      /* Tilføj ekstra tilbehør til listen  */
    addExtra() {
      if (this.extraName.trim() !== "") {
        this.extrasList.push(this.extraName.trim());
        this.extraName = "";
        this.errors.extrasList = "";
      }
    },
    /* Fjern ekstra tilbehør fra listen  */
    removeExtra(index) {
      this.extrasList.splice(index, 1);
    },
      /* Vælg stand på genstanden */
    selectCondition(value) {
      this.condition = value;
      this.errors.condition = "";
    },
    incrementField(field) {
      this[field] += 1;
    },
    decrementField(field, minValue) {
      if (this[field] > minValue) {
        this[field] -= 1;
      }
    },
    /* Validering af inputfelter før næste skridt */
     validate() {
      let valid = true;

      if (this.hasExtra === null) {
        this.errors.hasExtra = "Dette felt skal udfyldes";
        valid = false;
      } else {
        this.errors.hasExtra = "";
      }

      if (this.hasExtra && this.extrasList.length === 0) {
        this.errors.extrasList = "Indtast mindst ét tilbehør";
        valid = false;
      } else {
        this.errors.extrasList = "";
      }

      if (!this.condition) {
        this.errors.condition = "Dette felt skal udfyldes";
        valid = false;
      } else {
        this.errors.condition = "";
      }

      if (!this.minimumLoanPeriod || this.minimumLoanPeriod < 1) {
        this.minimumLoanPeriod = 1;
      }

      return valid;
    },
   /*  Gem detaljer og gå videre til næste skridt */
    next() {
      if (this.validate()) {
        const details = {
          hasExtra: this.hasExtra,
          extras: this.extrasList,
          condition: this.condition,
          quantity: this.quantity,
          minimumLoanPeriod: this.minimumLoanPeriod,
        };
        this.$emit("save-details", details,);
        this.$emit("go-to-confirm-item")
      }
    },
    back() {
      this.$emit("go-to-page-one");
    }
  },
};
</script>


<template>
  <v-container class="add-details-container">
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
    <Stepper :currentStep="currentStep" />

    <h1 class="mt-2 mb-2">Tilbehør og detaljer</h1>
    <p>
      Angiv stand, låneperiode og eventuelt tilbehør, der følger med genstanden.
    </p>

    <!-- Har genstanden ekstra tilbehør?  -->

    <h4>Har genstanden ekstra tilbehør?<span> *</span></h4>
    <v-row>
      <v-col cols="12">
        <v-btn
          class="ma-2 extra_button"
          size="large"
          :class="{ selected: hasExtra === true }"
          @click="selectExtra(true)"
        >
          Ja
        </v-btn>
        <v-btn
          class="ma-2 extra_button"
          size="large"
          :class="{ selected: hasExtra === false }"
          @click="selectExtra(false)"
        >
          Nej
        </v-btn>
        <div v-if="errors.hasExtra" class="error-text">{{ errors.hasExtra }}</div>
      </v-col>
    </v-row>

    <v-row v-if="hasExtra === true">
      <v-col cols="12">
        <div class="tags_wrapper" v-if="extrasList.length">
          <span class="tag" v-for="(extra, index) in extrasList" :key="index">
            {{  extra  }}
            <button class="remove_tag" @click="removeExtra(index)">×</button>
          </span>

        </div>

        <div class="input_wrapper">
          <input
            type="text"
            placeholder="F.eks. oplader, taske..."
            v-model="extraName"
            class="custom_input"
            @keyup.enter="addExtra"
          />

          <v-btn class="add_button" icon @click="addExtra"> + </v-btn>
        </div>
        <div v-if="errors.extrasList" class="error-text">{{ errors.extrasList }}</div>
      </v-col>
    </v-row>

    <!-- Vælg stand -->

    <h4>Stand<span> *</span></h4>
    <v-row>
      <v-col cols="12">
        <v-btn
          class="ma-2 condition_button"
          size="large"
          :class="{ selected: condition === 'Ny' }"
          @click="selectCondition('Ny')"
        >
          Ny
        </v-btn>
        <v-btn
          class="ma-2 condition_button"
          size="large"
          :class="{ selected: condition === 'God' }"
          @click="selectCondition('God')"
        >
          God
        </v-btn>
        <v-btn
          class="ma-2 condition_button"
          size="large"
          :class="{ selected: condition === 'Brugt' }"
          @click="selectCondition('Brugt')"
        >
          Brugt
        </v-btn>
        <v-btn
          class="ma-2 condition_button"
          size="large"
          :class="{ selected: condition === 'Slidt' }"
          @click="selectCondition('Slidt')"
        >
          Slidt
        </v-btn>
        <div v-if="errors.condition" class="error-text">{{ errors.condition }}</div>
      </v-col>
    </v-row>

    <section class="rental-options-section">
      <div class="number_field_group">
        <h3>Antal</h3>
        <p>Lad lejer vide hvor mange du har</p>
        <div class="number_stepper">
          <span>{{ quantity }}</span>
          <div class="number_controls">
            <button
              type="button"
              class="step_button decrement"
              aria-label="Reducer antal"
              @click="decrementField('quantity', 1)"
            >
              -
            </button>
            <button
              type="button"
              class="step_button increment"
              aria-label="Forøg antal"
              @click="incrementField('quantity')"
            >
              +
            </button>
          </div>
        </div>
      </div>

      <div class="number_field_group">
        <h3>Minimum lejeperiode</h3>
        <p>Hvor mange dage skal lejer mindst leje?</p>
        <div class="number_stepper">
          <input
            v-model.number="minimumLoanPeriod"
            type="number"
            min="1"
            class="number_input"
            aria-label="Minimum lejeperiode"
          />
          <div class="number_controls">
            <button
              type="button"
              class="step_button decrement"
              aria-label="Reducer minimum lejeperiode"
              @click="decrementField('minimumLoanPeriod', 1)"
            >
              -
            </button>
            <button
              type="button"
              class="step_button increment"
              aria-label="Forøg minimum lejeperiode"
              @click="incrementField('minimumLoanPeriod')"
            >
              +
            </button>
          </div>
        </div>
      </div>

    </section>

   <!--  Tilbage og næste knapper -->
      
    <div class="bottom-bar">
        <v-btn
          variant="tonal"
          rounded="lg"
          color="grey-darken-2"
          class="back-button"
          @click="back"
        >
          <v-icon start size="18">mdi-chevron-left</v-icon>
          Tilbage
        </v-btn>

        <v-btn
          color="primary"
          rounded="lg"
          class="create-button"
          @click="next"
        >
          Næste
        </v-btn>
      </div>

  </v-container>
</template>

<style scoped>

.add-details-container {
  padding-bottom: calc(96px + env(safe-area-inset-bottom));
}

.error-text {
  color: red;
  font-size: 14px;
  margin-top: 4px;
}

.extra_button {
  background-color: var(--color-surface);
  border: 2px solid var(--color-border);
  color: var(--color-neutral);
  font-weight: 500;
  min-width: 100px;
  border-radius: var(--radius-md);
  box-shadow: none;
}

.input_wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 8px;
}


.custom_input {
  flex: 1;
  margin: 0;
}

.custom_input{
  border-radius: var(--radius-md);
  border: 2px solid var(--color-input-border);  
  min-height: 44px;
  display: flex;
  align-items: center;
  padding: 0 12px;
  font-family: var(--font-body);
  font-size: var(--text-body);
}

.add_button {
  background-color: var(--color-primary);
  color: white;
  width: 56px;
  height: 56px;
  border-radius: var(--radius-lg);
  min-width: 0; /* IMPORTANT */
  font-size: 24px;
  padding: 0;
}

.tags_wrapper {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 8px;
}

.tag {
  background-color: var(--color-bg);
  color: var(--color-neutral);
  padding: 4px 10px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-full);
  display: flex;
  align-items: center;
  font-family: var(--font-body);
  font-size: var(--text-meta);
  font-weight: 500;
}

.remove_tag {
  background: transparent;
  border: none;
  color: black;
  font-weight: bold;
  margin-left: 6px;
  cursor: pointer;
}

.condition_button {
  background-color: var(--color-surface);
  border: 2px solid var(--color-border);
  color: var(--color-neutral);
  font-weight: 500;
  min-width: 100px;
  border-radius: var(--radius-md);
  box-shadow: none;
}

.rental-options-section {
  margin: 24px 0;
}

.rental-options-section h3 {
  margin: 0 0 8px;
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: 22px;
  font-weight: 800;
}

.number_stepper {
  width: 100%;
  min-height: 42px;
  border: 1px solid var(--color-input-border);
  border-radius: var(--radius-md);
  background: #ffffff;
}

.number_field_group {
  margin-top: 26px;
}

.number_field_group p {
  margin: 0 0 8px;
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-label);
  font-style: italic;
}

.number_stepper {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-left: 12px;
  overflow: hidden;
}

.number_stepper span {
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-body);
}

.number_input {
  width: 100%;
  min-width: 0;
  border: none;
  outline: none;
  background: transparent;
  color: var(--color-neutral);
  font-family: var(--font-body);
  font-size: var(--text-body);
}

.number_controls {
  display: flex;
  align-items: center;
  gap: 8px;
  padding-right: 6px;
}

.step_button {
  width: 30px;
  height: 30px;
  border: none;
  border-radius: var(--radius-full);
  color: #ffffff;
  cursor: pointer;
  font-family: var(--font-body);
  font-size: 24px;
  line-height: 1;
}

.step_button.decrement {
  background: #b8b6b3;
}

.step_button.increment {
  background: #f0a21a;
}


.selected {
  background-color: var(--color-primary) !important;
  color: white !important;
  
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


</style>
