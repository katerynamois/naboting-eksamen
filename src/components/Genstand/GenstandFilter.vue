<script>
export default {
    name: 'GenstandFilter',
    props: {
        activeFilter: {
            type: String,
            required: true
        }
    },
    emits: ['filterChanged'],
    data() {
        return {
                filters: ['Alle', 'Tilgængelig', 'Udlånt', 'Inaktiv']
        }
    },
    methods: {
        vælgFilter(filter) {
            this.$emit('filterChanged', filter)
        }
    }
}
</script>

<template>
    <nav class="filter-bar" aria-label="Filter items by status">
        <button
            v-for="filter in filters"
            :key="filter"
            class="filter-tab"
            :class="{ 'filter-tab-active': activeFilter === filter }"
            @click="vælgFilter(filter)"
            :aria-pressed="activeFilter === filter"
            :aria-label="`Vis ${filter === 'Alle' ? 'alle genstande' : filter}`"
        >
            {{ filter }}
        </button>

    </nav>
</template>

<style scoped>


.filter-bar {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    gap: var(--space-2);
    margin-bottom: var(--space-6);
    width: 100%;
    padding: 2px 0;
}


.filter-tab {
    font-family: var(--font-body);
    font-size: var(--text-label);
    font-weight: 600;
    color: var(--color-secondary);
    background: transparent;
    border: 1.5px solid var(--color-border);
    border-radius: var(--radius-full);
    padding: var(--space-2) var(--space-4);
    min-height: 44px;
    cursor: pointer;
    white-space: nowrap;
    flex: 1;
    transition: background 0.15s ease, color 0.15s ease, border-color 0.15s ease;
}


.filter-tab:hover {
    border-color: var(--color-primary);
    color: var(--color-primary);
}

/* Suppress focus ring on mouse click — active styling provides enough feedback */
.filter-tab:focus:not(:focus-visible) {
    outline: none;
}

/* Show focus ring only for keyboard navigation */
.filter-tab:focus-visible {
    outline: 3px solid var(--color-neutral);
    outline-offset: 3px;
}


.filter-tab-active {
    background: var(--color-primary) !important;
    color: #ffffff !important;
    border-color: var(--color-primary) !important;
    padding: var(--space-2) var(--space-4) !important;
}

</style>