<script>
export default {
    name: 'GenstandCard',
    components: {
    },
    data() {
        return {
        }
    },
    props: {
        id: {
            type: Number,
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
    },
    computed: {
        statusClass() {
        if (this.status === 'Tilgængelig') return 'status-available'
        if (this.status === 'Udlånt') return 'status-loaned'
        if (this.status === 'Inaktiv') return 'status-inactive'
    }
},
    methods: {
        handleClick() {
            this.$emit('cardClicked', this.id)
        }
    },
    watch: {
    },
    emits: ['cardClicked']
}
</script>

<template>
    <article class="card" @click="handleClick">

    <img
        :src="image"
        :alt="`Billede af ${title}`"
        class="card-image"
    />

    <div class="card-content">
        <div class="card-top">
            <h2 class="card-title">{{ title }}</h2>
            <span class="card-status" :class="statusClass">{{ status }}</span>
        </div>

        <p class="card-meta">
            {{ category }}
            <span v-if="brand"> · {{ brand }}</span>
        </p>

    </div>

    </article>
</template>

<style scoped>

.card {
    display: flex;
    flex-direction: row;
    align-items: center;
    gap: var(--space-3);
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-lg);
    padding: var(--space-3);
    width: 100%;
    cursor: pointer;
}


.card-image {
    width: 64px;
    height: 64px;
    border-radius: var(--radius-md);
    object-fit: cover;
    flex-shrink: 0;
}


.card-content {
    flex: 1;
}


.card-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 4px;
}


.card-title {
    font-family: var(--font-body);
    font-size: var(--text-body);
    font-weight: 600;
    color: var(--color-neutral);
    margin: 0;
}


.card-meta {
    font-family: var(--font-body);
    font-size: var(--text-label);
    color: var(--color-secondary);
    margin: 0;
}


.card-status {
    font-family: var(--font-body);
    font-size: 13px;
    font-weight: 600;
    padding: 5px 11px;
    border-radius: var(--radius-full);
    min-height: 32px;
    display: flex;
    align-items: center;
}


.status-available {
    background: var(--color-tilgaengelig-bg);
    color: var(--color-tilgaengelig-text);
}


.status-loaned {
    background: var(--color-udlaant-bg);
    color: var(--color-udlaant-text);
}


.status-inactive {
    background: var(--color-inaktiv-bg);
    color: var(--color-inaktiv-text);
}

</style>