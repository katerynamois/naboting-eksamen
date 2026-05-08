<script>
export default {
    name: 'GenstandEditModal',
    props: {
        title: { type: String, required: true },
        category: { type: String, default: '' },
        brand: { type: String, default: '' },
        condition: { type: String, default: '' },
        minimumLoanPeriod: { type: [Number, String], default: '' },
        quantity: { type: [Number, String], default: 1 },
    },
    emits: ['save', 'close'],
    data() {
        return {
            form: {
                title: this.title,
                category: this.category || '',
                brand: this.brand || '',
                condition: this.condition || '',
                minimumLoanPeriod: this.minimumLoanPeriod ?? '',
                quantity: this.quantity ?? 1,
            },
            conditionOptions: ['Ny', 'God', 'Brugt', 'Slidt'],
        }
    },
    methods: {
        save() {
            if (!this.form.title.trim()) return
            this.$emit('save', {
                title: this.form.title.trim(),
                category: this.form.category.trim(),
                brand: this.form.brand.trim() || null,
                condition: this.form.condition || null,
                minimumLoanPeriod: this.form.minimumLoanPeriod !== '' ? Number(this.form.minimumLoanPeriod) : null,
                quantity: this.form.quantity ? Number(this.form.quantity) : 1,
            })
        },
    },
}
</script>

<template>
    <div class="modal-overlay" @click.self="$emit('close')">
        <div class="modal-sheet">

            <div class="modal-header">
                <h2 class="modal-title">Rediger genstand</h2>
                <button class="modal-close" type="button" @click="$emit('close')">✕</button>
            </div>

            <form class="modal-form" @submit.prevent="save">

                <!-- Titel -->
                <div class="field-group">
                    <label class="field-label" for="edit-titel">Titel *</label>
                    <input
                        id="edit-titel"
                        v-model="form.title"
                        class="field-input"
                        type="text"
                        placeholder="Fx Boremaskine"
                        required
                    />
                </div>

                <!-- Kategori -->
                <div class="field-group">
                    <label class="field-label" for="edit-kategori">Kategori</label>
                    <input
                        id="edit-kategori"
                        v-model="form.category"
                        class="field-input"
                        type="text"
                        placeholder="Fx Værktøj"
                    />
                </div>

                <!-- Brand -->
                <div class="field-group">
                    <label class="field-label" for="edit-maerke">Mærke</label>
                    <input
                        id="edit-maerke"
                        v-model="form.brand"
                        class="field-input"
                        type="text"
                        placeholder="Fx Bosch"
                    />
                </div>

                <!-- Stand -->
                <div class="field-group">
                    <label class="field-label" for="edit-stand">Stand</label>
                    <select id="edit-stand" v-model="form.condition" class="field-input field-select">
                        <option value="">Vælg stand</option>
                        <option v-for="opt in conditionOptions" :key="opt" :value="opt">{{ opt }}</option>
                    </select>
                </div>

                <!-- Quantity and min. loan period side by side -->
                <div class="field-row">
                    <div class="field-group">
                        <label class="field-label" for="edit-antal">Antal</label>
                        <input
                            id="edit-antal"
                            v-model="form.quantity"
                            class="field-input"
                            type="number"
                            min="1"
                            placeholder="1"
                        />
                    </div>
                    <div class="field-group">
                        <label class="field-label" for="edit-laaneperiode">Min. lån (dage)</label>
                        <input
                            id="edit-laaneperiode"
                            v-model="form.minimumLoanPeriod"
                            class="field-input"
                            type="number"
                            min="1"
                            placeholder="Fx 3"
                        />
                    </div>
                </div>

                <button class="save-button" type="submit">Gem ændringer</button>

            </form>

        </div>
    </div>
</template>

<style scoped>
.modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.4);
    z-index: 100;
    display: flex;
    align-items: flex-end;
}

.modal-sheet {
    background: var(--color-surface);
    border-radius: var(--radius-lg) var(--radius-lg) 0 0;
    width: 100%;
    max-height: 90vh;
    overflow-y: auto;
    padding: var(--space-4);
    box-sizing: border-box;
}

.modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: var(--space-4);
}

.modal-title {
    font-family: var(--font-display);
    font-size: var(--text-h2);
    font-weight: 600;
    color: var(--color-neutral);
    margin: 0;
}

.modal-close {
    background: transparent;
    border: none;
    font-size: 18px;
    color: var(--color-secondary);
    cursor: pointer;
    padding: var(--space-2);
    min-height: 44px;
    min-width: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.modal-form {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
    padding-bottom: var(--space-6);
}

.field-group {
    display: flex;
    flex-direction: column;
    gap: var(--space-1);
    flex: 1;
}

.field-row {
    display: flex;
    gap: var(--space-3);
}

.field-label {
    font-family: var(--font-body);
    font-size: var(--text-label);
    font-weight: 600;
    color: var(--color-neutral);
}

.field-input {
    font-family: var(--font-body);
    font-size: var(--text-body);
    color: var(--color-neutral);
    background: var(--color-bg);
    border: 1px solid var(--color-input-border);
    border-radius: var(--radius-md);
    padding: 12px var(--space-3);
    min-height: 48px;
    box-sizing: border-box;
    outline: none;
    width: 100%;
}

.field-input:focus {
    border-color: var(--color-primary);
}

.field-select {
    appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%236b6763' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 14px center;
    padding-right: 36px;
    cursor: pointer;
}

.save-button {
    margin-top: var(--space-2);
    width: 100%;
    min-height: 48px;
    background: var(--color-primary);
    color: #ffffff;
    border: none;
    border-radius: var(--radius-md);
    font-family: var(--font-body);
    font-size: var(--text-label);
    font-weight: 700;
    cursor: pointer;
}
</style>
