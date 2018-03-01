max_threads = 99

def mothur(command, **kwargs):
    return ( "mothur '#{command}(".format(command=command)
           + ", ".join(["{key}={val}".format(key=key, val=kwargs[key]) for key in kwargs])
           + ")'"
           + "\n"
           )

rule link_clones:
    output: 'seq/clones.v4.fn'
    input: 'raw/clones.v4.fn'
    shell: "ln -frs {input} {output}"

rule link_refs:
    output: 'seq/refs.v4.fn'
    input: 'raw/refs.v4.fn'
    shell: "ln -frs {input} {output}"

rule combine_data:
    output: 'seq/all.v4.fn'
    input: raw="seq/clones.v4.fn", ref="seq/refs.v4.fn"
    shell:
        "cat {input.raw} {input.ref} > {output}"

rule align_rrs_v4:
    output: 'seq/{stem}.v4.afn'
    input: seqs='seq/{stem}.v4.fn', refs='ref/silva.seed.pcr_v4.afn'
    shadow: 'full'
    threads: max_threads
    shell: (mothur('align.seqs', fasta='{input.seqs}', reference='{input.refs}', processors='{threads}') + 'mv seq/{wildcards.stem}.v4.align {output}')

rule squeeze_alignment:
    output: 'seq/{stem}.sqz.afn'
    input: script='scripts/squeeze_alignment.py', seq='seq/{stem}.afn'
    shell: "{input.script} '-.acgtu' < {input.seq} > {output}"

rule trim_alignment_ends:
    output: 'seq/{stem}.trim.afn'
    input: script='scripts/trim_alignment_ends.py', seq='seq/{stem}.afn'
    shell: "{input.script} '-.acgtu' < {input.seq} > {output}"

rule tree_nucl:
    output: 'res/{stem}.nwk'
    input: 'seq/{stem}.afn'
    shell:
        "FastTree -nt < {input} > {output}"
