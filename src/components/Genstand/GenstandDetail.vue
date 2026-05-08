<script>
import GenstandEditModal from './GenstandEditModal.vue'

const STATUS_CLASS_MAP = {
    'Tilgængelig': 'status-available',
    'Udlånt': 'status-loaned',
    'Inaktiv': 'status-inactive',
}

const STATUS_OPTION_MAP = {
    'Tilgængelig': 'available',
    'Udlånt': 'loaned',
    'Inaktiv': 'inactive',
}

export default {
    name: 'GenstandDetail',
    components: {
        GenstandEditModal,
    },
    data() {
        return {
            showEditModal: false,
        }
    },
    props: {
        id: {
            type: [Number, String],
            required: true
        },
        title: {
            type: String,
            required: true
        },
        category: {
            type: String,
            required: true
        },
        brand: {
            type: String,
            default: null
        },
        status: {
            type: String,
            required: true
        },
        image: {
            type: String,
            required: true
        },
        condition: {
            type: String,
            default: null
        },
        minimumLoanPeriod: {
            type: [Number, String],
            default: null
        },
        quantity: {
            type: [Number, String],
            default: 1
        },
        accessories: {
            type: Array,
            default: () => [],
        },
        totalLoans: {
            type: Number,
            default: 0
        },
        activeLoans: {
            type: Number,
            default: 0
        },
        createdAt: {
            type: String,
            default: null
        },
        user: {
            type: Object,
            default: null
        }
    },
    computed: {
        statusClass() {
            return STATUS_CLASS_MAP[this.status] || ''
        },
        accessoriesList() {
            return this.accessories || []
        },
        minLoanPeriodText() {
            if (this.minimumLoanPeriod === null || this.minimumLoanPeriod === undefined || this.minimumLoanPeriod === '') {
                return 'Ikke angivet'
            }
            return typeof this.minimumLoanPeriod === 'number' ? `${this.minimumLoanPeriod} dage` : this.minimumLoanPeriod
        },
        createdAtText() {
            if (!this.createdAt) return ''
            const date = new Date(this.createdAt)
            return `Oprettet ${date.toLocaleDateString('da-DK', { day: 'numeric', month: 'long', year: 'numeric' })}`
        }
    },
    methods: {
        statusOptionClass(option) {
            const key = STATUS_OPTION_MAP[option] || option.toLowerCase()
            return `status-option--${key}`
        },
        updateStatus(newStatus) {
            this.$emit('update-status', {
                id: this.id,
                status: newStatus
            })
        },
        deleteItem() {
            if (window.confirm('Vil du slette denne genstand?')) {
                this.$emit('delete-item', this.id)
            }
        },
        handleSaveEdit(updatedFields) {
            this.$emit('edit-item', { id: this.id, ...updatedFields })
            this.showEditModal = false
        },
    },
    emits: ['gåTilbage', 'update-status', 'delete-item', 'edit-item']
}
</script>

<template>
    <div class="detail-page">

        <header class="detail-header">
            <button class="back-button" @click="$emit('gåTilbage')">
                Tilbage
            </button>
        </header>

        <figure class="detail-image-wrapper">
            <img
                :src="image"
                :alt="`Billede af ${title}`"
                class="detail-image"
            />
            <span class="detail-status" :class="statusClass">
                <span class="detail-status-dot" aria-hidden="true"></span>
                {{ status }}
            </span>
        </figure>

        <section class="detail-info">
            <h1 class="detail-title">{{ title }}</h1>
            <p class="detail-meta">
                {{ category }}
                <span v-if="brand"> · {{ brand }}</span>
                <span v-if="condition"> · {{ condition }}</span>
            </p>
        </section>

        <section class="detail-boxes" aria-label="Genstandsdetaljer">

            <div class="detail-box">
                <span class="detail-box-label">Min. lån</span>
                <span class="detail-box-number detail-box-number--period">
                    {{ minLoanPeriodText }}
                </span>
            </div>

            <div v-if="accessories && accessories.length" class="detail-box detail-box-accessories">
                <div class="detail-box-top">
                    <h3 class="detail-box-heading">Tilbehør</h3>
                </div>
                <div class="detail-chips">
                    <span
                        v-for="item in accessoriesList"
                        :key="item"
                        class="detail-chip"
                    >
                        {{ item }}
                    </span>
                </div>
            </div>

        </section>

        <section class="detail-owner" aria-label="Ejeroplysninger">
            <div class="detail-owner-avatar">{{ user ? user.initials : 'DG' }}</div>
            <div class="detail-owner-info">
                <p class="detail-owner-name">{{ user ? user.name : 'Din genstand' }}</p>
                <p class="detail-owner-date">{{ createdAtText }}</p>
            </div>
            <div class="detail-status-actions">
                <button
                    v-for="option in ['Tilgængelig', 'Udlånt', 'Inaktiv']"
                    :key="option"
                    class="status-option"
                    :class="[statusOptionClass(option), { 'status-option--active': status === option }]"
                    type="button"
                    @click="updateStatus(option)"
                >
                    {{ option }}
                </button>
            </div>
            <button
                class="edit-button"
                type="button"
                @click="showEditModal = true"
            >
                Rediger genstand
            </button>
            <button
                class="delete-item-button"
                type="button"
                @click="deleteItem"
            >
                Slet genstand
            </button>
        </section>

        <GenstandEditModal
            v-if="showEditModal"
            :title="title"
            :category="category"
            :brand="brand"
            :condition="condition"
            :minimumLoanPeriod="minimumLoanPeriod"
            :quantity="quantity"
            @save="handleSaveEdit"
            @close="showEditModal = false"
        />

        <section class="detail-stats" aria-label="Statistik for din genstand">
            <div class="detail-stat-box">
                <span class="detail-stat-number">{{ totalLoans }}</span>
                <span class="detail-stat-label">Lån i alt</span>
            </div>
            <div class="detail-stat-box">
                <span class="detail-stat-number">{{ activeLoans }}</span>
                <span class="detail-stat-label">Aktive lån</span>
            </div>
        </section>

    </div>
</template>

<style scoped>

.detail-page {
    background: var(--color-bg);
    min-height: 100vh;
    padding: var(--space-4);
    box-sizing: border-box;
}

.detail-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: var(--space-4);
}

.back-button {
    background: transparent;
    color: #111111;
    border: none;
    font-family: var(--font-body);
    font-size: var(--text-body);
    font-weight: 500;
    cursor: pointer;
    padding: var(--space-3) 0;
    min-height: 44px;
}

.detail-image-wrapper {
    position: relative;
    margin: 0 0 20px 0;
    border-radius: var(--radius-lg);
    overflow: hidden;
    background: #ffffff;
}

.detail-image {
    width: 100%;
    height: 220px;
    object-fit: contain;
    display: block;
}

.detail-status {
    position: absolute;
    bottom: 12px;
    right: 12px;
    display: inline-flex;
    align-items: center;
    gap: 5px;
    font-family: var(--font-body);
    font-size: 13px;
    font-weight: 600;
    padding: 5px 11px;
    border-radius: var(--radius-full);
    min-height: 32px;
}

.detail-status-dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    flex-shrink: 0;
}

.status-available {
    background: var(--color-tilgaengelig-bg);
    color: var(--color-tilgaengelig-text);
}
.status-available .detail-status-dot {
    background: var(--color-tilgaengelig-dot);
}

.status-loaned {
    background: var(--color-udlaant-bg);
    color: var(--color-udlaant-text);
}
.status-loaned .detail-status-dot {
    background: var(--color-udlaant-dot);
}

.status-inactive {
    background: var(--color-inaktiv-bg);
    color: var(--color-inaktiv-text);
}
.status-inactive .detail-status-dot {
    background: var(--color-inaktiv-dot);
}

.detail-title {
    font-family: var(--font-display);
    font-size: var(--text-h1);
    font-weight: 600;
    color: var(--color-neutral);
    margin: 0 0 6px 0;
}

.detail-meta {
    font-family: var(--font-body);
    font-size: var(--text-label);
    color: var(--color-secondary);
    margin: 0 0 20px 0;
}

.detail-boxes {
    display: flex;
    gap: var(--space-3);
    margin-bottom: var(--space-4);
    align-items: stretch;
}

.detail-box {
    flex: 1;
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-lg);
    padding: var(--space-4);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 4px;
    text-align: center;
}

.detail-box-accessories {
    flex: 2;
    align-items: flex-start;
    text-align: left;
    justify-content: flex-start;
}

.detail-box-top {
    display: flex;
    align-items: center;
    gap: 6px;
    margin-bottom: 8px;
}

.detail-box-heading {
    font-family: var(--font-body);
    font-size: 13px;
    font-weight: 600;
    color: var(--color-secondary);
    margin: 0;
    white-space: nowrap;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.detail-box-label {
    font-family: var(--font-body);
    font-size: var(--text-meta);
    font-weight: 500;
    color: var(--color-secondary);
}

.detail-box-number {
    font-family: var(--font-body);
    font-size: 32px;
    font-weight: 700;
    color: var(--color-neutral);
    line-height: 1;
}

.detail-box-number--period {
    font-size: 24px;
    line-height: 1.2;
}

.detail-box-unit {
    font-family: var(--font-body);
    font-size: var(--text-meta);
    font-weight: 500;
    color: var(--color-secondary);
}

.detail-chips {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
}

.detail-chip {
    font-family: var(--font-body);
    font-size: var(--text-meta);
    font-weight: 500;
    color: var(--color-neutral);
    background: var(--color-bg);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-full);
    padding: 4px 10px;
}

.detail-owner {
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-lg);
    padding: var(--space-4);
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: var(--space-3);
    margin-bottom: var(--space-4);
    margin-top: 4px;
}

.detail-owner-avatar {
    width: 44px;
    height: 44px;
    border-radius: var(--radius-full);
    background: var(--color-primary);
    color: #ffffff;
    font-family: var(--font-body);
    font-size: var(--text-label);
    font-weight: 600;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.detail-owner-info {
    flex: 1;
    min-width: 0;
}

.detail-owner-name {
    font-family: var(--font-body);
    font-size: var(--text-label);
    font-weight: 600;
    color: var(--color-neutral);
    margin: 0 0 2px 0;
}

.detail-owner-date {
    font-family: var(--font-body);
    font-size: var(--text-meta);
    color: var(--color-secondary);
    margin: 0;
    white-space: nowrap;
}

.detail-status-actions {
    flex: 0 0 100%;
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: var(--space-2);
}

.status-option {
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    background: #ffffff;
    color: var(--color-neutral);
    cursor: pointer;
    font-family: var(--font-body);
    font-size: var(--text-meta);
    font-weight: 600;
    min-height: 40px;
    padding: 0 var(--space-2);
}

.status-option--active {
    border-color: transparent;
}

.status-option--available.status-option--active {
    background: var(--color-tilgaengelig-bg);
    color: var(--color-tilgaengelig-text);
}

.status-option--loaned.status-option--active {
    background: var(--color-udlaant-bg);
    color: var(--color-udlaant-text);
}

.status-option--inactive.status-option--active {
    background: var(--color-inaktiv-bg);
    color: var(--color-inaktiv-text);
}

.edit-button {
    flex: 0 0 100%;
    min-height: 42px;
    border: 1px solid var(--color-primary);
    border-radius: var(--radius-md);
    background: var(--color-primary);
    color: #ffffff;
    cursor: pointer;
    font-family: var(--font-body);
    font-size: var(--text-label);
    font-weight: 700;
}

.delete-item-button {
    flex: 0 0 100%;
    min-height: 42px;
    border: 1px solid var(--color-accent);
    border-radius: var(--radius-md);
    background: #ffffff;
    color: var(--color-accent);
    cursor: pointer;
    font-family: var(--font-body);
    font-size: var(--text-label);
    font-weight: 700;
}

.detail-stats {
    display: flex;
    gap: var(--space-3);
    margin-bottom: var(--space-6);
}

.detail-stat-box {
    flex: 1;
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-lg);
    padding: var(--space-4) var(--space-3);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    text-align: center;
}

.detail-stat-number {
    font-family: var(--font-body);
    font-size: 22px;
    font-weight: 600;
    color: var(--color-neutral);
}

.detail-stat-label {
    font-family: var(--font-body);
    font-size: var(--text-meta);
    color: var(--color-secondary);
}

</style>
