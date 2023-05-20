module fbeg::Switch

import List;
import Map;

import lang::flybytes::Syntax;

@javaClass{fbeg.Switch}
java int hashCode(str s);

private alias StrCase = tuple[str, list[Stat]];
private alias HashCase = tuple[int, StrCase];

private int cnt = 0;

private HashCase withHash(StrCase c) = <hashCode(c[0]), c>;

/**
 * Generates a Switch statement with string keys.
 * If the code block of a case does not end with a break or return statement,
 * it will fall through to the default case.
 *
 * @param arg   Reference to the key to evaluate in the Switch statement.
 * @param cases A map containing all cases, mapping each string key to the corresponding code block.
 * @param def   The default case
 */
Stat stringSwitch(Exp arg, map[str,list[Stat]] cases, list[Stat] def = []) {
    // Build relation that groups cases with the same key hashcode.
    // For tuple t <- hashCases, t[0] is a string hashcode, and t[1] is a list of cases having that key hashcode.
    // For tuple c <- t[1], c[0] is the key and c[1] represents the code block belonging to that switch case.
    lrel[int,list[StrCase]] hashCases = toList(toMap(mapper(toList(cases), withHash)));
    cnt = cnt + 1;
    return  \switch(
                invokeVirtual(
                    string(),
                    arg,
                    methodDesc(
                        integer(),
                        "hashCode",
                        []
                    ),
                    []
                ),
                [
                    \case(t[0],                                                     // Build case for each tuple t <- hashCases
                        [                                                           // Build equals call with code block for each tuple c <- t[1]
                            \if(
                                invokeVirtual(
                                    string(),
                                    arg,
                                    methodDesc(
                                        boolean(),
                                        "equals",
                                        [object()]
                                    ),
                                    [sconst(c[0])]
                                ),
                                c[1]
                            )
                        | c <- t[1]]                                                // Add equals call with code block for each key belonging to this hash code
                        + (isEmpty(def) ? \break() : \asm([GOTO("LSDEF<cnt>")]))    // If no key matches, break or go to the default case
                    ) | t <- hashCases
                ] + \default([block(def, label = "LSDEF<cnt>")])
            );
}